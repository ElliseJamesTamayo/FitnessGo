from pydantic import BaseModel
from typing import Optional


class LoginRequest(BaseModel):
    username: str
    password: str


class RegisterRequest(BaseModel):
    Username: str
    Email: str
    Password: str
    Fullname: str
    Age: int
    Gender: str
    Height: float
    Weight: float
    Goal: str
    ActivityLevel: str
    DesiredWeight: Optional[float] = None
    HasHealthConditions: str = "No"
    WhatHealthConditions: Optional[str] = None