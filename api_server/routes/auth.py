from fastapi import APIRouter, HTTPException

from my_connector import auth_tbl
from api_server.schemas.auth_schema import LoginRequest, RegisterRequest

router = APIRouter()


@router.get("/test-db")
def test_db():
    return {
        "connected": auth_tbl.db is not None
    }


@router.post("/login")
def login(payload: LoginRequest):
    user_id = auth_tbl.check_password(
        payload.username,
        payload.password
    )

    if not user_id:
        raise HTTPException(
            status_code=401,
            detail="Invalid username or password"
        )

    return {
        "success": True,
        "UserId": user_id,
        "message": "Login successful"
    }


@router.post("/register")
def register(payload: RegisterRequest):
    if auth_tbl.username_exists(payload.Username):
        raise HTTPException(
            status_code=400,
            detail="Username already exists"
        )

    if auth_tbl.email_exists(payload.Email):
        raise HTTPException(
            status_code=400,
            detail="Email already exists"
        )

    try:
        user_id, bmi, bmi_status, daily_goal = auth_tbl.insert_info(
            username=payload.Username,
            email=payload.Email,
            password=payload.Password,
            fullname=payload.Fullname,
            age=payload.Age,
            gender=payload.Gender,
            height=payload.Height,
            weight=payload.Weight,
            goal=payload.Goal,
            activity=payload.ActivityLevel,
            desired_weight=payload.DesiredWeight,
            has_health_condition=payload.HasHealthConditions,
            specific_condition=payload.WhatHealthConditions
        )

        return {
            "success": True,
            "UserId": user_id,
            "BMI": bmi,
            "BMIStatus": bmi_status,
            "DailyNetGoal": daily_goal,
            "message": "Registration successful"
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )