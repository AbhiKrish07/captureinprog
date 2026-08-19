from fastapi import APIRouter, Depends, HTTPException, Query
from supabase import Client
from typing import List, Dict, Any
from pydantic import BaseModel
from models.schemas import SpaceCreate, SpaceUpdate, Space, SpaceContext, SpaceChatRequest, SpaceChatResponse, User, Capture
from dependencies import get_supabase_client, get_current_user
import uuid

router = APIRouter(prefix="/spaces", tags=["spaces"])

@router.post("", response_model=Space)
async def create_space(
    request: SpaceCreate,
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        space_data = {
            "user_id": str(current_user.id),
            "name": request.name,
            "description": request.description,
            "canvas_state": request.canvas_state or {},
            "capture_ids": [],
            "capture_count": 0
        }
        
        res = supabase.table("spaces").insert(space_data).execute()
        
        if not res.data:
            raise HTTPException(status_code=500, detail="Failed to create space")
            
        return Space(**res.data[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("", response_model=Dict[str, List[Space]])
async def list_spaces(
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        res = supabase.table("spaces")\
            .select("*")\
            .order("created_at", desc=True)\
            .execute()
            
        return {"spaces": [Space(**item) for item in res.data]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{space_id}/context", response_model=SpaceContext)
async def get_space_context(
    space_id: str,
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        # Get the space
        space_res = supabase.table("spaces").select("*").eq("id", space_id).execute()
        if not space_res.data:
            raise HTTPException(status_code=404, detail="Space not found")
        
        space_data = space_res.data[0]
        capture_ids = space_data.get("capture_ids", [])
        
        captures = []
        if capture_ids:
            # Fetch the associated captures without embeddings
            captures_res = supabase.table("captures")\
                .select("id, user_id, type, content, title, preview, metadata, space_ids, created_at, updated_at")\
                .in_("id", capture_ids)\
                .execute()
            captures = captures_res.data
            
        # Combine them into the context
        context_data = {
            **space_data,
            "captures": captures
        }
        
        return SpaceContext(**context_data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

from core.ai import generate_chat_response
import json

@router.post("/{space_id}/chat", response_model=SpaceChatResponse)
async def chat_in_space(
    space_id: str,
    request: SpaceChatRequest,
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        # Get the space and its captures for context
        space_res = supabase.table("spaces").select("*").eq("id", space_id).execute()
        if not space_res.data:
            raise HTTPException(status_code=404, detail="Space not found")
            
        space_data = space_res.data[0]
        capture_ids = space_data.get("capture_ids", [])
        
        context_text = ""
        sources = []
        
        if capture_ids:
            captures_res = supabase.table("captures")\
                .select("id, title, content, type")\
                .in_("id", capture_ids)\
                .execute()
            
            captures = captures_res.data
            for cap in captures:
                context_text += f"\n--- Capture: {cap.get('title') or 'Untitled'} (Type: {cap.get('type')}) ---\n"
                context_text += f"{cap.get('content')}\n"
                sources.append(cap.get("id"))
                
        if not context_text:
            context_text = "No captures available in this space."

        # Format history (assuming request.message is the latest user message)
        # For a full chat app, we would receive the entire chat history in SpaceChatRequest.
        # Here we just pass the latest message.
        messages = [{"role": "user", "content": request.message}]
        
        # Call Groq AI
        ai_response = await generate_chat_response(messages=messages, context_text=context_text)
        
        return SpaceChatResponse(
            response=ai_response,
            sources=sources
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class AddCaptureRequest(BaseModel):
    capture_id: str

@router.post("/{space_id}/captures")
async def add_capture_to_space(
    space_id: str,
    request: AddCaptureRequest,
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        # Get space
        space_res = supabase.table("spaces").select("capture_ids, capture_count").eq("id", space_id).execute()
        if not space_res.data:
            raise HTTPException(status_code=404, detail="Space not found")
            
        capture_ids = space_res.data[0].get("capture_ids", [])
        if request.capture_id in capture_ids:
            return {"status": "already_added"}
            
        capture_ids.append(request.capture_id)
        
        # Update space
        supabase.table("spaces").update({
            "capture_ids": capture_ids,
            "capture_count": len(capture_ids)
        }).eq("id", space_id).execute()
        
        # Also update the capture's space_ids array
        cap_res = supabase.table("captures").select("space_ids").eq("id", request.capture_id).execute()
        if cap_res.data:
            c_space_ids = cap_res.data[0].get("space_ids", [])
            if space_id not in c_space_ids:
                c_space_ids.append(space_id)
                supabase.table("captures").update({"space_ids": c_space_ids}).eq("id", request.capture_id).execute()
                
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{space_id}", response_model=Space)
async def update_space(
    space_id: str,
    request: SpaceUpdate,
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        update_data = {}
        if request.name is not None:
            update_data["name"] = request.name
        if request.description is not None:
            update_data["description"] = request.description
        if request.canvas_state is not None:
            update_data["canvas_state"] = request.canvas_state
            
        if not update_data:
            raise HTTPException(status_code=400, detail="No fields to update")
            
        res = supabase.table("spaces").update(update_data).eq("id", space_id).execute()
        
        if not res.data:
            raise HTTPException(status_code=404, detail="Space not found")
            
        return Space(**res.data[0])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{space_id}")
async def delete_space(
    space_id: str,
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        res = supabase.table("spaces").delete().eq("id", space_id).execute()
        return {"success": True}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{space_id}/captures/{capture_id}")
async def remove_capture_from_space(
    space_id: str,
    capture_id: str,
    current_user: User = Depends(get_current_user),
    supabase: Client = Depends(get_supabase_client)
):
    try:
        # Get space
        space_res = supabase.table("spaces").select("capture_ids").eq("id", space_id).execute()
        if not space_res.data:
            raise HTTPException(status_code=404, detail="Space not found")
            
        capture_ids = space_res.data[0].get("capture_ids", [])
        if capture_id in capture_ids:
            capture_ids.remove(capture_id)
            
            # Update space
            supabase.table("spaces").update({
                "capture_ids": capture_ids,
                "capture_count": len(capture_ids)
            }).eq("id", space_id).execute()
            
        # Update the capture's space_ids array
        cap_res = supabase.table("captures").select("space_ids").eq("id", capture_id).execute()
        if cap_res.data:
            c_space_ids = cap_res.data[0].get("space_ids", [])
            if space_id in c_space_ids:
                c_space_ids.remove(space_id)
                supabase.table("captures").update({"space_ids": c_space_ids}).eq("id", capture_id).execute()
                
        return {"success": True}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
