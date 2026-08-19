from pydantic import BaseModel, EmailStr, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from uuid import UUID

# User Schemas
class User(BaseModel):
    id: UUID
    email: str
    created_at: datetime

# Auth Schemas
class SignupRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class AuthResponse(BaseModel):
    token: str
    user: User

# Capture Schemas
class CaptureBase(BaseModel):
    type: str
    content: str
    title: Optional[str] = None
    preview: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = Field(default_factory=dict)
    space_ids: Optional[List[UUID]] = Field(default_factory=list)

class CaptureCreate(CaptureBase):
    pass

class CaptureUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None
    preview: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None
    space_ids: Optional[List[UUID]] = None

class Capture(CaptureBase):
    id: UUID
    user_id: UUID
    embedding: Optional[List[float]] = None
    created_at: datetime
    updated_at: datetime

class CaptureListResponse(BaseModel):
    items: List[Capture]
    total: int

class CaptureSearchResponse(BaseModel):
    results: List[dict] # Will include Capture + relevance_score
    message: Optional[str] = None
    synthesis: Optional[str] = None
    sources: Optional[List[UUID]] = None

class SearchRequest(BaseModel):
    query: str
    space_id: Optional[str] = None
    synthesize: bool = False

# Space Schemas
class SpaceBase(BaseModel):
    name: str
    description: Optional[str] = None
    canvas_state: Optional[Dict[str, Any]] = None

class SpaceCreate(SpaceBase):
    pass

class SpaceUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    canvas_state: Optional[Dict[str, Any]] = None

class Space(SpaceBase):
    id: UUID
    user_id: UUID
    capture_ids: List[UUID]
    capture_count: int
    created_at: datetime

class SpaceContext(Space):
    captures: List[Capture]

class SpaceChatRequest(BaseModel):
    message: str

class SpaceChatResponse(BaseModel):
    response: str
    sources: List[UUID]
