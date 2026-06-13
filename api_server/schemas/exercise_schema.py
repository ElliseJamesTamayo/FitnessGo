from pydantic import BaseModel
from typing import Optional


class UserExerciseCreate(BaseModel):
    UserId: int
    Goal: Optional[str] = None
    Category: Optional[str] = None
    Name: str
    Meaning: Optional[str] = None
    Steps: Optional[str] = None
    Benefits: Optional[str] = None
    Difficulty: Optional[str] = None
    ProgramName: Optional[str] = None
    Sets: Optional[int] = 3
    Reps: Optional[str] = "12"
    RestSeconds: Optional[int] = 30
    Mode: Optional[str] = "normal"


class UserExerciseUpdate(BaseModel):
    Goal: Optional[str] = None
    Category: Optional[str] = None
    Name: str
    Meaning: Optional[str] = None
    Steps: Optional[str] = None
    Benefits: Optional[str] = None
    Difficulty: Optional[str] = None
    ProgramName: Optional[str] = None
    Sets: Optional[int] = 3
    Reps: Optional[str] = "12"
    RestSeconds: Optional[int] = 30
    Mode: Optional[str] = "normal"


class SavedExerciseCreate(BaseModel):
    UserId: int
    UserExerciseId: Optional[int] = None
    name: str
    difficulty: Optional[str] = None
    program_name: Optional[str] = None
    sets: int = 3
    reps: int = 12
    rest_seconds: str = "30"