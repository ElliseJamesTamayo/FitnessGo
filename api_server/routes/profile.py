from fastapi import APIRouter, HTTPException

from my_connector import auth_tbl
from api_server.schemas.profile_schema import ProfileUpdate
from api_server.db_utils import fetch_one

router = APIRouter()


@router.get("/{user_id}")
def get_profile(user_id: int):
    profile = fetch_one(
        """
        SELECT UserId, Username, Email, Fullname, Age, Gender,
               Height, Weight, ActivityLevel, Goal, DesiredWeight,
               HasHealthConditions, WhatHealthConditions, BMI,
               DailyNetGoal, BMIStatus, LastLogin, AccountStatus,
               ViolationCount, DeactivationReason, Created_at, Updated_at
        FROM data_db
        WHERE UserId = %s
        LIMIT 1
        """,
        (user_id,)
    )

    if not profile:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    return profile


@router.put("/{user_id}")
def update_profile(user_id: int, payload: ProfileUpdate):
    updated = auth_tbl.update_user_profile(
        user_id=user_id,
        username=payload.Username,
        fullname=payload.Fullname,
        age=payload.Age,
        gender=payload.Gender,
        height=payload.Height,
        weight=payload.Weight,
        activity=payload.ActivityLevel,
        has_condition=payload.HasHealthConditions,
        condition=payload.WhatHealthConditions
    )

    return {
        "success": updated
    }