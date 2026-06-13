from fastapi import APIRouter, HTTPException

from my_connector import auth_tbl
from api_server.schemas.post_schema import (
    PostCreate,
    PostUpdate,
    PostAudienceUpdate
)
from api_server.db_utils import fetch_one, fetch_all, execute_query

router = APIRouter()


@router.get("/")
def get_all_posts():
    return {
        "success": True,
        "posts": auth_tbl.get_all_posts()
    }


@router.get("/{post_id}")
def get_post(post_id: int):
    post = auth_tbl.get_post_by_id(post_id)

    if not post:
        raise HTTPException(
            status_code=404,
            detail="Post not found"
        )

    return post


@router.get("/user/{user_id}/all")
def get_user_posts(user_id: int):
    return {
        "success": True,
        "posts": auth_tbl.get_user_posts(user_id)
    }


@router.post("/")
def create_post(payload: PostCreate):
    result = execute_query(
        """
        INSERT INTO posts_tb
        (UserId, PostText, Audience, Desired, Created_at, Updated_at)
        VALUES (%s, %s, %s, %s, NOW(), NOW())
        """,
        (
            payload.UserId,
            payload.PostText,
            payload.Audience,
            payload.Desired
        )
    )

    if not result["success"]:
        raise HTTPException(
            status_code=400,
            detail=result["error"]
        )

    return {
        "success": True,
        "PostId": result["lastrowid"]
    }


@router.put("/{post_id}")
def update_post(post_id: int, payload: PostUpdate):
    updated = auth_tbl.update_post_content(
        post_id,
        payload.PostText
    )

    return {
        "success": updated
    }


@router.put("/{post_id}/audience")
def update_post_audience(post_id: int, payload: PostAudienceUpdate):
    updated = auth_tbl.update_post_audience(
        post_id,
        payload.Audience
    )

    return {
        "success": updated
    }


@router.delete("/{post_id}")
def delete_post(post_id: int):
    deleted = auth_tbl.delete_post(post_id)

    return {
        "success": deleted
    }