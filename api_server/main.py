from fastapi import FastAPI

from api_server.routes import health
from api_server.routes import auth
from api_server.routes import profile
from api_server.routes import food
from api_server.routes import articles
from api_server.routes import posts
from api_server.routes import exercise
from api_server.routes import chat

app = FastAPI(
    title="FitnessGo API",
    version="1.0.0"
)

app.include_router(
    health.router,
    prefix="/health",
    tags=["Health"]
)

app.include_router(
    auth.router,
    prefix="/auth",
    tags=["Authentication / data_db"]
)

app.include_router(
    profile.router,
    prefix="/profile",
    tags=["Profile / data_db"]
)

app.include_router(
    food.router,
    prefix="/foods",
    tags=["food_db"]
)

app.include_router(
    articles.router,
    prefix="/articles",
    tags=["articles_db / saved_articles_db"]
)

app.include_router(
    posts.router,
    prefix="/posts",
    tags=["posts_tb"]
)

app.include_router(
    exercise.router,
    prefix="/exercise",
    tags=["user_exercises / saved_exercises_by_user"]
)

app.include_router(
    chat.router,
    prefix="/chat",
    tags=["ai_chats / ai_messages"]
)
