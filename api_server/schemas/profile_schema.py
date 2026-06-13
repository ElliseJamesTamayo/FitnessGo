from pydantic import BaseModel
from typing import Optional


class ProfileUpdate(BaseModel):
    Username: str
    Fullname: str
    Age: int
    Gender: str
    Height: float
    Weight: float
    ActivityLevel: str
    HasHealthConditions: str
    WhatHealthConditions: Optional[str] = None