from fastapi import APIRouter, HTTPException, UploadFile, File
from fastapi.responses import Response

from my_connector import auth_tbl
from api_server.schemas.post_schema import (
    PostCreate,
    PostUpdate,
    PostAudienceUpdate
)
from api_server.db_utils import fetch_one, fetch_all, execute_query

router = APIRouter()


def bytes_from_db(value):
    if value is None:
        return None

    if isinstance(value, bytes):
        return value

    if isinstance(value, bytearray):
        return bytes(value)

    if isinstance(value, memoryview):
        return value.tobytes()

    return value


@router.get("/")
def get_all_posts():
    posts = fetch_all(
        '''
        SELECT
            p.PostId,
            p.UserId,
            p.PostText,
            p.Audience,
            p.Desired,
            p.Created_at,
            p.Updated_at,
            p.IsViolated,
            p.ViolatedAt,

            COALESCE(u.Fullname, u.Username, 'User') AS Fullname,
            COALESCE(u.Username, '') AS Username,

            CASE
                WHEN p.PostImage IS NULL THEN 0
                ELSE 1
            END AS HasPhoto
        FROM posts_tb p
        LEFT JOIN data_db u ON p.UserId = u.UserId
        WHERE p.Audience = 'Public'
        ORDER BY p.Created_at DESC
        '''
    )

    return {
        "success": True,
        "posts": posts
    }


@router.get("/user/{user_id}/all")
def get_user_posts(user_id: int):
    posts = fetch_all(
        '''
        SELECT
            p.PostId,
            p.UserId,
            p.PostText,
            p.Audience,
            p.Desired,
            p.Created_at,
            p.Updated_at,
            p.IsViolated,
            p.ViolatedAt,

            COALESCE(u.Fullname, u.Username, 'User') AS Fullname,
            COALESCE(u.Username, '') AS Username,

            CASE
                WHEN p.PostImage IS NULL THEN 0
                ELSE 1
            END AS HasPhoto
        FROM posts_tb p
        LEFT JOIN data_db u ON p.UserId = u.UserId
        WHERE p.UserId = %s
        ORDER BY p.Created_at DESC
        ''',
        (user_id,)
    )

    return {
        "success": True,
        "posts": posts
    }


@router.put("/{post_id}/image")
async def upload_post_image(post_id: int, image: UploadFile = File(...)):
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(
            status_code=400,
            detail="Uploaded file must be an image."
        )

    image_bytes = await image.read()

    if not image_bytes:
        raise HTTPException(
            status_code=400,
            detail="Image file is empty."
        )

    result = execute_query(
        '''
        UPDATE posts_tb
        SET PostImage = %s, Updated_at = NOW()
        WHERE PostId = %s
        ''',
        (
            image_bytes,
            post_id
        )
    )

    if not result["success"]:
        raise HTTPException(
            status_code=400,
            detail=result["error"]
        )

    return {
        "success": True,
        "message": "Post image uploaded successfully."
    }


@router.get("/{post_id}/image")
def get_post_image(post_id: int):
    post = fetch_one(
        '''
        SELECT PostImage
        FROM posts_tb
        WHERE PostId = %s
        ''',
        (post_id,)
    )

    if not post:
        raise HTTPException(
            status_code=404,
            detail="Post not found"
        )

    image_bytes = bytes_from_db(post.get("PostImage"))

    if not image_bytes:
        raise HTTPException(
            status_code=404,
            detail="Post image not found"
        )

    return Response(
        content=image_bytes,
        media_type="image/jpeg"
    )


@router.get("/{post_id}")
def get_post(post_id: int):
    post = fetch_one(
        '''
        SELECT
            p.PostId,
            p.UserId,
            p.PostText,
            p.Audience,
            p.Desired,
            p.Created_at,
            p.Updated_at,
            p.IsViolated,
            p.ViolatedAt,

            COALESCE(u.Fullname, u.Username, 'User') AS Fullname,
            COALESCE(u.Username, '') AS Username,

            CASE
                WHEN p.PostImage IS NULL THEN 0
                ELSE 1
            END AS HasPhoto
        FROM posts_tb p
        LEFT JOIN data_db u ON p.UserId = u.UserId
        WHERE p.PostId = %s
        ''',
        (post_id,)
    )

    if not post:
        raise HTTPException(
            status_code=404,
            detail="Post not found"
        )

    return {
        "success": True,
        "post": post
    }


@router.post("/")
def create_post(payload: PostCreate):
    result = execute_query(
        '''
        INSERT INTO posts_tb
        (UserId, PostText, Audience, Desired, Created_at, Updated_at)
        VALUES (%s, %s, %s, %s, NOW(), NOW())
        ''',
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
        "message": "Post created successfully.",
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
