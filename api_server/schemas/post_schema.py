from pydantic import BaseModel
from typing import Optional


class PostCreate(BaseModel):
    UserId: int
    PostText: str
    Audience: str = "Public"
    Desired: Optional[str] = None


class PostUpdate(BaseModel):
    PostText: str


class PostAudienceUpdate(BaseModel):
    Audience: str