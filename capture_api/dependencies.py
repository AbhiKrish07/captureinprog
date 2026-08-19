from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from supabase import create_client, Client
from core.config import settings

security = HTTPBearer()

def get_supabase_client() -> Client:
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_ANON_KEY)

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    supabase: Client = Depends(get_supabase_client)
):
    token = credentials.credentials
    try:
        # Verify the JWT token and get user info
        user_resp = supabase.auth.get_user(token)
        if not user_resp or not user_resp.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired token",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        # Set the token on the supabase client so RLS and Storage work
        supabase.postgrest.auth(token)
        # Force the storage client and other requests to use this auth token
        supabase.options = supabase.options or {}
        if not hasattr(supabase.options, 'headers'):
            supabase.options.headers = {}
        supabase.options.headers["Authorization"] = f"Bearer {token}"
        
        return user_resp.user
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Authentication failed: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )
