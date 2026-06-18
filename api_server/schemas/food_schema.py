from pydantic import BaseModel


class FoodCalculateRequest(BaseModel):
    FoodName: str
    FoodQuantity: float


class FoodCreate(BaseModel):
    UserId: int
    FoodName: str
    FoodQuantity: float
    MealCategory: str
    Calories: float


class FoodUpdate(BaseModel):
    FoodName: str
    FoodQuantity: float
    MealCategory: str
    Calories: float