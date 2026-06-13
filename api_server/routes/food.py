from datetime import date

from fastapi import APIRouter, HTTPException, Query

from my_connector import auth_tbl
from api_server.schemas.food_schema import FoodCreate, FoodUpdate
from api_server.db_utils import fetch_all

router = APIRouter()


@router.post("/")
def create_food(payload: FoodCreate):
    food_id = auth_tbl.insert_food(
        user_id=payload.UserId,
        food_name=payload.FoodName,
        quantity=payload.FoodQuantity,
        meal_category=payload.MealCategory,
        calories=payload.Calories
    )

    if not food_id:
        raise HTTPException(
            status_code=400,
            detail="Food was not inserted"
        )

    return {
        "success": True,
        "FoodId": food_id
    }


@router.get("/user/{user_id}")
def get_food_by_user_and_date(
    user_id: int,
    log_date: str = Query(default=None)
):
    if log_date is None:
        log_date = date.today().isoformat()

    rows = auth_tbl.get_user_food_entries_by_date(
        user_id=user_id,
        date_str=log_date
    )

    return {
        "success": True,
        "UserId": user_id,
        "date": log_date,
        "foods": rows or []
    }


@router.get("/user/{user_id}/all")
def get_all_food_by_user(user_id: int):
    rows = fetch_all(
        """
        SELECT FoodId, UserId, FoodName, FoodQuantity,
               MealCategory, Calories, Created_at, Updated_at
        FROM food_db
        WHERE UserId = %s
        ORDER BY Created_at DESC
        """,
        (user_id,)
    )

    return {
        "success": True,
        "foods": rows
    }


@router.put("/{food_id}")
def update_food(food_id: int, payload: FoodUpdate):
    data = {
        "FoodId": food_id,
        "FoodName": payload.FoodName,
        "FoodQuantity": payload.FoodQuantity,
        "MealCategory": payload.MealCategory,
        "Calories": payload.Calories
    }

    updated = auth_tbl.update_food_entry_by_id(data)

    return {
        "success": updated
    }


@router.delete("/{food_id}")
def delete_food(food_id: int):
    deleted = auth_tbl.delete_food_entry_by_id(food_id)

    return {
        "success": deleted
    }