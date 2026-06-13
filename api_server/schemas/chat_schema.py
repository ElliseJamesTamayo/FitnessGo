from pydantic import BaseModel
from typing import Optional


class ChatCreate(BaseModel):
    user_id: int
    title: Optional[str] = "AI Fitness Buddy"


class MessageCreate(BaseModel):
    chat_id: int
    role: str
    content: str