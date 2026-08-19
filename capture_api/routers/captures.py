from fastapi import APIRouter, Depends, HTTPException, Query, UploadFile, File, Form
from supabase import Client
from typing import List
from models.schemas import CaptureCreate, CaptureUpdate, Capture, CaptureListResponse, CaptureSearchResponse, User, SearchRequest
from dependencies import get_supabase_client, get_current_user
from services.embeddings import generate_embedding
from core.ai import get_groq_client, synthesize_search_results
import uuid

router = APIRouter(prefix="/captures", tags=["captures"])

@router.post("", response_model=Capture)
async def create_capture(
    request: CaptureCreate,
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        content_to_embed = f"{request.title or ''} {request.content}".strip()
        
        # Fetch link content if type is link
        if request.type == 'link':
            try:
                import httpx
                from bs4 import BeautifulSoup
                with httpx.Client(timeout=5.0) as client:
                    resp = client.get(request.content)
                    if resp.status_code == 200:
                        soup = BeautifulSoup(resp.text, 'html.parser')
                        page_text = soup.get_text(separator=' ', strip=True)
                        if page_text:
                            content_to_embed = f"{request.title or ''} {page_text}".strip()
            except Exception as e:
                print(f"Error fetching link: {e}")

        embedding = generate_embedding(content_to_embed) if content_to_embed else None
        
        # Prepare data for Supabase insertion
        capture_data = {
            "user_id": str(current_user.id),
            "type": request.type,
            "content": request.content,
            "title": request.title,
            "preview": request.preview or request.content[:200],
            "embedding": embedding,
            "metadata": request.metadata,
            "space_ids": [str(sid) for sid in request.space_ids] if request.space_ids else []
        }
        
        # Insert into database
        res = supabase.table("captures").insert(capture_data).execute()
        
        if not res.data:
            raise HTTPException(status_code=500, detail="Failed to create capture")
            
        return Capture(**res.data[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/upload", response_model=Capture)
async def upload_capture(
    file: UploadFile = File(...),
    type: str = Form(...),
    title: str = Form(None),
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        # Read file content
        file_bytes = await file.read()
        
        # Generate unique filename
        ext = file.filename.split(".")[-1] if file.filename and "." in file.filename else ""
        filename = f"{current_user.id}/{uuid.uuid4()}.{ext}" if ext else f"{current_user.id}/{uuid.uuid4()}"
        
        # Upload to Supabase Storage
        res_storage = supabase.storage.from_("captures").upload(
            file=file_bytes,
            path=filename,
            file_options={"content-type": file.content_type}
        )
        
        # Get public URL
        public_url = supabase.storage.from_("captures").get_public_url(filename)
        
        # Extract text based on file type
        extracted_text = ""
        needs_ocr = False
        import base64
        
        if type == 'pdf':
            from io import BytesIO
            from pypdf import PdfReader
            try:
                reader = PdfReader(BytesIO(file_bytes))
                for page in reader.pages:
                    text = page.extract_text()
                    if text:
                        extracted_text += text + "\n"
                if not extracted_text.strip():
                    needs_ocr = True
            except Exception as e:
                print(f"Error parsing PDF: {e}")
                needs_ocr = True
        elif type == 'image':
            from core.ai import generate_image_description
            b64 = base64.b64encode(file_bytes).decode('utf-8')
            desc = await generate_image_description(b64, file.content_type or "image/jpeg")
            if desc:
                extracted_text = desc

        # Generate embedding
        content_to_embed = f"{title or file.filename or ''} {extracted_text}".strip()
        embedding = generate_embedding(content_to_embed) if content_to_embed else None
        
        metadata = {}
        if needs_ocr:
            metadata["needs_ocr"] = True
            metadata["status"] = "partial"
        else:
            metadata["status"] = "success"
        
        # Prepare data for Supabase insertion
        capture_data = {
            "user_id": str(current_user.id),
            "type": type,
            "content": public_url,
            "title": title or file.filename,
            "preview": extracted_text[:200] if extracted_text else public_url,
            "embedding": embedding,
            "metadata": metadata,
        }
        
        # Insert into database
        res = supabase.table("captures").insert(capture_data).execute()
        
        if not res.data:
            raise HTTPException(status_code=500, detail="Failed to create capture")
            
        return Capture(**res.data[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/transcribe", response_model=Capture)
async def transcribe_capture(
    file: UploadFile = File(...),
    title: str = Form(None),
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        file_bytes = await file.read()
        
        # 1. Transcribe with Groq
        groq_client = get_groq_client()
        if not groq_client:
            raise HTTPException(status_code=500, detail="GROQ_API_KEY is not set.")
            
        transcription = await groq_client.audio.transcriptions.create(
            file=(file.filename, file_bytes),
            model="whisper-large-v3",
            response_format="json"
        )
        content = transcription.text
        
        # 2. Upload audio to Storage (optional, but good for keeping original)
        ext = file.filename.split(".")[-1] if file.filename and "." in file.filename else "m4a"
        filename = f"{current_user.id}/voice_{uuid.uuid4()}.{ext}"
        
        supabase.storage.from_("captures").upload(
            file=file_bytes,
            path=filename,
            file_options={"content-type": file.content_type}
        )
        audio_url = supabase.storage.from_("captures").get_public_url(filename)
        
        # 3. Create a text capture with the transcription, and link the audio
        embedding = generate_embedding(content)
        
        capture_data = {
            "user_id": str(current_user.id),
            "type": "voice",
            "content": content,
            "title": title or "Voice Note",
            "preview": content[:200],
            "embedding": embedding,
            "metadata": {"audio_url": audio_url, "status": "success"}
        }
        
        res = supabase.table("captures").insert(capture_data).execute()
        
        if not res.data:
            raise HTTPException(status_code=500, detail="Failed to create capture")
            
        return Capture(**res.data[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("", response_model=CaptureListResponse)
async def list_captures(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    module: str = Query(None, description="Filter captures by metadata->>'module'"),
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        # We don't return embeddings in the list view to save bandwidth
        query = supabase.table("captures").select("id, user_id, type, content, title, preview, metadata, space_ids, created_at, updated_at")
        
        if module:
            query = query.eq("metadata->>module", module)
            
        res = query.order("created_at", desc=True).range(offset, offset + limit - 1).execute()
            
        count_query = supabase.table("captures").select("id", count="exact")
        if module:
            count_query = count_query.eq("metadata->>module", module)
            
        count_res = count_query.execute()
        total = count_res.count if count_res.count else len(res.data)
        
        return CaptureListResponse(
            items=[Capture(**item) for item in res.data],
            total=total
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{capture_id}", response_model=Capture)
async def get_capture(
    capture_id: str,
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        res = supabase.table("captures").select("*").eq("id", capture_id).execute()
        if not res.data:
            raise HTTPException(status_code=404, detail="Capture not found")
        return Capture(**res.data[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.patch("/{capture_id}", response_model=Capture)
async def update_capture(
    capture_id: str,
    request: CaptureUpdate,
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        # Fetch current to see if we need to re-embed
        current_res = supabase.table("captures").select("*").eq("id", capture_id).execute()
        if not current_res.data:
            raise HTTPException(status_code=404, detail="Capture not found")
            
        current = current_res.data[0]
        
        updates = {}
        if request.title is not None:
            updates["title"] = request.title
        if request.content is not None:
            updates["content"] = request.content
        if request.preview is not None:
            updates["preview"] = request.preview
        if request.metadata is not None:
            # We merge metadata rather than fully replacing, or if we want full replace we can.
            # Usually for PATCH it's better to replace the whole JSONB dictionary if provided
            updates["metadata"] = request.metadata
        if request.space_ids is not None:
            updates["space_ids"] = [str(sid) for sid in request.space_ids]
            
        # Re-embed if title or content changed
        if request.content is not None or request.title is not None:
            new_title = request.title if request.title is not None else current.get("title")
            new_content = request.content if request.content is not None else current.get("content")
            content_to_embed = f"{new_title or ''} {new_content or ''}".strip()
            
            if content_to_embed:
                updates["embedding"] = generate_embedding(content_to_embed)
            
        if not updates:
            return Capture(**current)
            
        res = supabase.table("captures").update(updates).eq("id", capture_id).execute()
        if not res.data:
            raise HTTPException(status_code=500, detail="Failed to update capture")
            
        return Capture(**res.data[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/search", response_model=CaptureSearchResponse)
async def search_captures(
    request: SearchRequest,
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    search_text = request.query
    if not search_text:
        raise HTTPException(status_code=400, detail="Missing query string")
        
    try:
        # Generate embedding for the search query
        query_embedding = generate_embedding(search_text)
        
        # Call the Supabase RPC function for pgvector similarity search
        rpc_params = {
            "query_embedding": query_embedding,
            "match_threshold": 0.5, # We can adjust this threshold for higher confidence
            "match_count": 20
        }
        
        if request.space_id:
            rpc_params["filter_space_id"] = request.space_id
            
        res = supabase.rpc("match_captures", rpc_params).execute()
        
        results = res.data or []
        
        if not results:
            return CaptureSearchResponse(
                results=[],
                message="No relevant captures found for your query."
            )
            
        synthesis = None
        sources = None
        
        if request.synthesize:
            top_captures = results[:5] # Use top 5 for synthesis context
            synthesis, sources = await synthesize_search_results(search_text, top_captures)
            
        return CaptureSearchResponse(
            results=results,
            synthesis=synthesis,
            sources=sources
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{capture_id}")
async def delete_capture(
    capture_id: str,
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        supabase.table("captures").delete().eq("id", capture_id).execute()
        return {"success": True}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
