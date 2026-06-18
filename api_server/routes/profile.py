from pathlib import Path

from fastapi import APIRouter, HTTPException, UploadFile, File
from fastapi.responses import FileResponse

from my_connector import auth_tbl
from api_server.schemas.profile_schema import ProfileUpdate
from api_server.db_utils import fetch_one

router = APIRouter()

PHOTO_DIR = Path("/home/ubuntu/profile_photos")


def detect_photo_type(photo_bytes: bytes):
    if photo_bytes.startswith(b"\xff\xd8"):
        return "jpg", "image/jpeg"

    if photo_bytes.startswith(b"\x89PNG\r\n\x1a\n"):
        return "png", "image/png"

    if photo_bytes.startswith(b"RIFF") and b"WEBP" in photo_bytes[:20]:
        return "webp", "image/webp"

    return "jpg", "image/jpeg"


def photo_path_for(user_id: int):
    for ext in ("jpg", "jpeg", "png", "webp"):
        path = PHOTO_DIR / f"{user_id}.{ext}"
        if path.exists():
            return path

    return None


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


@router.put("/{user_id}/photo")
async def update_profile_photo(user_id: int, image: UploadFile = File(...)):
    try:
        photo_bytes = await image.read()

        if not photo_bytes:
            raise HTTPException(
                status_code=400,
                detail="No image uploaded"
            )

        success = auth_tbl.update_photo(user_id, photo_bytes)

        if not success:
            raise HTTPException(
                status_code=500,
                detail="Failed to update profile photo"
            )

        PHOTO_DIR.mkdir(parents=True, exist_ok=True)

        for old_path in PHOTO_DIR.glob(f"{user_id}.*"):
            old_path.unlink(missing_ok=True)

        ext, _ = detect_photo_type(photo_bytes)
        cached_path = PHOTO_DIR / f"{user_id}.{ext}"
        cached_path.write_bytes(photo_bytes)

        return {
            "success": True,
            "message": "Profile photo updated successfully"
        }

    except HTTPException:
        raise

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


@router.get("/{user_id}/photo")
def get_profile_photo(user_id: int):
    path = photo_path_for(user_id)

    if not path:
        raise HTTPException(
            status_code=404,
            detail="Profile photo not found"
        )

    suffix = path.suffix.lower()

    if suffix in (".jpg", ".jpeg"):
        media_type = "image/jpeg"
    elif suffix == ".png":
        media_type = "image/png"
    elif suffix == ".webp":
        media_type = "image/webp"
    else:
        media_type = "application/octet-stream"

    return FileResponse(
        path=str(path),
        media_type=media_type,
        headers={
            "Cache-Control": "no-store"
        }
    )
