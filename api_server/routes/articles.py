from fastapi import APIRouter, HTTPException

from my_connector import auth_tbl
from api_server.schemas.article_schema import (
    ArticleCreate,
    ArticleUpdate,
    SavedArticleCreate
)
from api_server.db_utils import fetch_one

router = APIRouter()


@router.get("/")
def get_all_articles():
    return {
        "success": True,
        "articles": auth_tbl.get_all_articles()
    }


@router.get("/{article_id}")
def get_article(article_id: int):
    article = fetch_one(
        """
        SELECT ArticleId, category, title, author, date,
               body, image, Created_at
        FROM articles_db
        WHERE ArticleId = %s
        LIMIT 1
        """,
        (article_id,)
    )

    if not article:
        raise HTTPException(
            status_code=404,
            detail="Article not found"
        )

    return article


@router.post("/")
def create_article(payload: ArticleCreate):
    created = auth_tbl.add_article_to_db(payload.model_dump())

    return {
        "success": created
    }


@router.put("/{article_id}")
def update_article(article_id: int, payload: ArticleUpdate):
    updated = auth_tbl.update_article(
        article_id,
        payload.model_dump()
    )

    return {
        "success": updated
    }


@router.delete("/{article_id}")
def delete_article(article_id: int):
    deleted = auth_tbl.delete_article(article_id)

    return {
        "success": deleted
    }


@router.post("/saved")
def save_article(payload: SavedArticleCreate):
    article_data = payload.model_dump()
    user_id = article_data.pop("UserId")

    saved = auth_tbl.save_article(
        user_id=user_id,
        article=article_data
    )

    return {
        "success": saved
    }


@router.get("/saved/user/{user_id}")
def get_saved_articles(user_id: int):
    return {
        "success": True,
        "saved_articles": auth_tbl.get_saved_articles(user_id)
    }


@router.delete("/saved/{saved_id}")
def delete_saved_article(saved_id: int):
    deleted = auth_tbl.delete_saved_article(saved_id)

    return {
        "success": deleted
    }