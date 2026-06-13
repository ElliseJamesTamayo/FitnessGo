from pydantic import BaseModel
from typing import Optional


class ArticleCreate(BaseModel):
    category: str
    title: str
    author: str
    date: str
    body: str
    image: Optional[str] = "logo.png"


class ArticleUpdate(BaseModel):
    category: str
    title: str
    author: str
    date: str
    body: str
    image: Optional[str] = "logo.png"


class SavedArticleCreate(BaseModel):
    UserId: int
    ArticleId: Optional[int] = None
    category: str
    title: str
    author: str
    date: str
    body: str
    image: Optional[str] = ""