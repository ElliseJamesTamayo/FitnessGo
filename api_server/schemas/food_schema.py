from pydantic import BaseModel


class FoodCreate(BaseModel):
    UserId: int
    FoodName: str
    FoodQuantity: int
    MealCategory: str
    Calories: float


class FoodUpdate(BaseModel):
    FoodName: str
    FoodQuantity: int
    MealCategory: str
    Calories: float