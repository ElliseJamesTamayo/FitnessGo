from fastapi import APIRouter, HTTPException

from my_connector import auth_tbl
from api_server.schemas.chat_schema import ChatCreate, MessageCreate
from api_server.db_utils import fetch_all, execute_query

router = APIRouter()


@router.post("/chats")
def create_chat(payload: ChatCreate):
    result = execute_query(
        """
        INSERT INTO ai_chats
        (user_id, title, created_at, updated_at)
        VALUES (%s, %s, NOW(), NOW())
        """,
        (
            payload.user_id,
            payload.title
        )
    )

    if not result["success"]:
        raise HTTPException(
            status_code=400,
            detail=result["error"]
        )

    return {
        "success": True,
        "chat_id": result["lastrowid"]
    }


@router.post("/chats/start/{user_id}")
def get_or_create_chat(user_id: int):
    chat_id = auth_tbl.get_or_create_chat(user_id)

    return {
        "success": chat_id is not None,
        "chat_id": chat_id
    }


@router.get("/chats/user/{user_id}")
def get_user_chats(user_id: int):
    rows = fetch_all(
        """
        SELECT chat_id, user_id, title, created_at, updated_at
        FROM ai_chats
        WHERE user_id = %s
        ORDER BY updated_at DESC
        """,
        (user_id,)
    )

    return {
        "success": True,
        "chats": rows
    }


@router.delete("/chats/{chat_id}")
def delete_chat(chat_id: int):
    delete_messages = execute_query(
        """
        DELETE FROM ai_messages
        WHERE chat_id = %s
        """,
        (chat_id,)
    )

    delete_chat_result = execute_query(
        """
        DELETE FROM ai_chats
        WHERE chat_id = %s
        LIMIT 1
        """,
        (chat_id,)
    )

    return {
        "success": delete_chat_result["success"],
        "messages_deleted": delete_messages["rowcount"],
        "chats_deleted": delete_chat_result["rowcount"]
    }


@router.post("/messages")
def create_message(payload: MessageCreate):
    message_id = auth_tbl.save_message(
        chat_id=payload.chat_id,
        role=payload.role,
        content=payload.content
    )

    if not message_id:
        raise HTTPException(
            status_code=400,
            detail="Message was not saved"
        )

    return {
        "success": True,
        "message_id": message_id
    }


@router.get("/messages/{chat_id}")
def get_messages(chat_id: int):
    rows = fetch_all(
        """
        SELECT message_id, chat_id, role, content, timestamp
        FROM ai_messages
        WHERE chat_id = %s
        ORDER BY timestamp ASC
        """,
        (chat_id,)
    )

    return {
        "success": True,
        "messages": rows
    }


@router.delete("/messages/{message_id}")
def delete_message(message_id: int):
    deleted = auth_tbl.delete_message(message_id)

    return {
        "success": deleted
    }