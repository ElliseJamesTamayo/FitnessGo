from datetime import date

from fastapi import APIRouter, HTTPException, Query

from my_connector import auth_tbl
from api_server.schemas.food_schema import FoodCreate, FoodUpdate, FoodCalculateRequest
from api_server.db_utils import fetch_all

import os
import requests

router = APIRouter()


@router.post("/calculate")
def calculate_food_calories(food: FoodCalculateRequest):
    food_item = food.FoodName.strip()
    food_quantity = food.FoodQuantity

    if not food_item:
        raise HTTPException(status_code=400, detail="Food name is required.")

    if food_quantity <= 0:
        raise HTTPException(status_code=400, detail="Quantity must be greater than 0.")

    api_key = "xkFc9jtNjCRrd7sdLRckPA==J9LAgoqCUBOn3xFC"

    if not api_key:
        raise HTTPException(status_code=500, detail="Calorie Ninjas API key is missing.")

    url = "https://api.calorieninjas.com/v1/nutrition"
    headers = {
        "X-Api-Key": api_key
    }

    query_text = f"{food_quantity}g {food_item}"

    try:
        response = requests.get(
            url,
            headers=headers,
            params={"query": query_text},
            timeout=10,
        )
    except requests.RequestException as error:
        raise HTTPException(
            status_code=500,
            detail=f"Failed to connect to Calorie Ninjas API: {str(error)}",
        )

    if response.status_code != 200:
        raise HTTPException(
            status_code=response.status_code,
            detail=response.text,
        )

    data = response.json()

    if isinstance(data, dict):
        items = data.get("items", [])
    elif isinstance(data, list):
        items = data
    else:
        items = []

    total_calories = sum(
        float(item.get("calories", 0))
        for item in items
        if isinstance(item, dict)
    )

    return {
        "success": True,
        "FoodName": food_item,
        "FoodQuantity": food_quantity,
        "Calories": round(total_calories, 2),
        "items": items,
    }


@router.get("/calories")
def get_food_calories(
    food_name: str = Query(...),
    grams: float = Query(100)
):
    calories = auth_tbl.get_food_calories(food_name, grams)

    return {
        "success": True,
        "food_name": food_name,
        "grams": grams,
        "calories": calories
    }


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