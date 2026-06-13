"""
FitnessGo API Client
Place this file in the ROOT of your Kivy project:
FitnessGo2.0 - Copy/api_client.py

This file lets your Kivy app call your FastAPI backend instead of calling MySQL directly.
"""

import requests

BASE_URL = "http://127.0.0.1:8000"
DEFAULT_TIMEOUT = 10


def _request(method, endpoint, json=None, params=None, files=None, data=None, timeout=DEFAULT_TIMEOUT):
    """Reusable request helper for all API calls."""
    url = f"{BASE_URL}{endpoint}"

    try:
        response = requests.request(
            method=method,
            url=url,
            json=json,
            params=params,
            files=files,
            data=data,
            timeout=timeout,
        )

        try:
            result = response.json()
        except ValueError:
            result = {"message": response.text}

        if response.status_code >= 400:
            return {
                "success": False,
                "status_code": response.status_code,
                "message": result.get("detail") or result.get("message") or "API request failed",
                "data": result,
            }

        return result

    except requests.exceptions.RequestException as e:
        return {
            "success": False,
            "message": str(e),
        }


# =========================================================
# HEALTH
# =========================================================

def test_db():
    return _request("GET", "/auth/test-db")


def health_check():
    return _request("GET", "/health/")


# =========================================================
# AUTH / data_db
# =========================================================

def login_user(username, password):
    return _request(
        "POST",
        "/auth/login",
        json={
            "username": username,
            "password": password,
        },
    )


def register_user(
    username,
    email,
    password,
    fullname,
    age,
    gender,
    height,
    weight,
    goal,
    activity_level,
    desired_weight=None,
    has_health_conditions="No",
    what_health_conditions=None,
):
    return _request(
        "POST",
        "/auth/register",
        json={
            "Username": username,
            "Email": email,
            "Password": password,
            "Fullname": fullname,
            "Age": age,
            "Gender": gender,
            "Height": height,
            "Weight": weight,
            "Goal": goal,
            "ActivityLevel": activity_level,
            "DesiredWeight": desired_weight,
            "HasHealthConditions": has_health_conditions,
            "WhatHealthConditions": what_health_conditions,
        },
    )


# =========================================================
# PROFILE / data_db
# =========================================================

def get_profile(user_id):
    return _request("GET", f"/profile/{user_id}")


def update_profile(
    user_id,
    username,
    fullname,
    age,
    gender,
    height,
    weight,
    activity_level,
    has_health_conditions,
    what_health_conditions=None,
):
    return _request(
        "PUT",
        f"/profile/{user_id}",
        json={
            "Username": username,
            "Fullname": fullname,
            "Age": age,
            "Gender": gender,
            "Height": height,
            "Weight": weight,
            "ActivityLevel": activity_level,
            "HasHealthConditions": has_health_conditions,
            "WhatHealthConditions": what_health_conditions,
        },
    )


# =========================================================
# FOOD / food_db
# =========================================================

def create_food(user_id, food_name, quantity, meal_category, calories):
    return _request(
        "POST",
        "/foods/",
        json={
            "UserId": user_id,
            "FoodName": food_name,
            "FoodQuantity": int(float(quantity)),
            "MealCategory": meal_category,
            "Calories": float(calories),
        },
    )


def get_foods_by_date(user_id, log_date):
    return _request(
        "GET",
        f"/foods/user/{user_id}",
        params={"log_date": log_date},
    )


def get_all_foods_by_user(user_id):
    return _request("GET", f"/foods/user/{user_id}/all")


def update_food(food_id, food_name, quantity, meal_category, calories):
    return _request(
        "PUT",
        f"/foods/{food_id}",
        json={
            "FoodName": food_name,
            "FoodQuantity": int(float(quantity)),
            "MealCategory": meal_category,
            "Calories": float(calories),
        },
    )


def delete_food(food_id):
    return _request("DELETE", f"/foods/{food_id}")


# =========================================================
# ARTICLES / articles_db and saved_articles_db
# =========================================================

def get_articles():
    return _request("GET", "/articles/")


def get_article(article_id):
    return _request("GET", f"/articles/{article_id}")


def create_article(category, title, author, date, body, image="logo.png"):
    return _request(
        "POST",
        "/articles/",
        json={
            "category": category,
            "title": title,
            "author": author,
            "date": date,
            "body": body,
            "image": image,
        },
    )


def update_article(article_id, category, title, author, date, body, image="logo.png"):
    return _request(
        "PUT",
        f"/articles/{article_id}",
        json={
            "category": category,
            "title": title,
            "author": author,
            "date": date,
            "body": body,
            "image": image,
        },
    )


def delete_article(article_id):
    return _request("DELETE", f"/articles/{article_id}")


def save_article(user_id, article):
    """article should be a dict with ArticleId, category, title, author, date, body, image."""
    return _request(
        "POST",
        "/articles/saved",
        json={
            "UserId": user_id,
            "ArticleId": article.get("ArticleId"),
            "category": article.get("category", ""),
            "title": article.get("title", ""),
            "author": article.get("author", ""),
            "date": article.get("date", ""),
            "body": article.get("body", ""),
            "image": article.get("image", ""),
        },
    )


def get_saved_articles(user_id):
    return _request("GET", f"/articles/saved/user/{user_id}")


def delete_saved_article(saved_id):
    return _request("DELETE", f"/articles/saved/{saved_id}")


# =========================================================
# POSTS / posts_tb
# =========================================================

def get_all_posts():
    return _request("GET", "/posts/")


def get_post(post_id):
    return _request("GET", f"/posts/{post_id}")


def get_user_posts(user_id):
    return _request("GET", f"/posts/user/{user_id}/all")


def create_post(user_id, post_text, audience="Public", desired=None):
    # Current backend route supports text fields only.
    # Image upload should be added later as a separate multipart endpoint.
    return _request(
        "POST",
        "/posts/",
        json={
            "UserId": user_id,
            "PostText": post_text,
            "Audience": audience,
            "Desired": desired,
        },
    )


def update_post(post_id, post_text):
    return _request(
        "PUT",
        f"/posts/{post_id}",
        json={"PostText": post_text},
    )


def update_post_audience(post_id, audience):
    return _request(
        "PUT",
        f"/posts/{post_id}/audience",
        json={"Audience": audience},
    )


def delete_post(post_id):
    return _request("DELETE", f"/posts/{post_id}")


# =========================================================
# EXERCISES / user_exercises and saved_exercises_by_user
# =========================================================

def get_user_exercises(user_id):
    return _request("GET", f"/exercises/user/{user_id}")


def get_exercise(exercise_id):
    return _request("GET", f"/exercises/{exercise_id}")


def create_user_exercise(payload):
    return _request("POST", "/exercises/", json=payload)


def update_user_exercise(exercise_id, payload):
    return _request("PUT", f"/exercises/{exercise_id}", json=payload)


def delete_user_exercise(exercise_id):
    return _request("DELETE", f"/exercises/{exercise_id}")


def get_saved_exercises(user_id):
    return _request("GET", f"/exercises/saved/user/{user_id}")


def save_exercise(user_id, name, difficulty=None, program_name=None, sets=3, reps=12, rest_seconds="30", user_exercise_id=None):
    return _request(
        "POST",
        "/exercises/saved",
        json={
            "UserId": user_id,
            "UserExerciseId": user_exercise_id,
            "name": name,
            "difficulty": difficulty,
            "program_name": program_name,
            "sets": sets,
            "reps": reps,
            "rest_seconds": rest_seconds,
        },
    )


def delete_saved_exercise(saved_exercise_id):
    return _request("DELETE", f"/exercises/saved/{saved_exercise_id}")


# =========================================================
# CHAT / ai_chats and ai_messages
# =========================================================

def create_chat(user_id, title="AI Fitness Buddy"):
    return _request(
        "POST",
        "/chat/chats",
        json={"user_id": user_id, "title": title},
    )


def start_chat(user_id):
    return _request("POST", f"/chat/chats/start/{user_id}")


def get_user_chats(user_id):
    return _request("GET", f"/chat/chats/user/{user_id}")


def delete_chat(chat_id):
    return _request("DELETE", f"/chat/chats/{chat_id}")


def create_message(chat_id, role, content):
    return _request(
        "POST",
        "/chat/messages",
        json={
            "chat_id": chat_id,
            "role": role,
            "content": content,
        },
    )


def get_messages(chat_id):
    return _request("GET", f"/chat/messages/{chat_id}")


def delete_message(message_id):
    return _request("DELETE", f"/chat/messages/{message_id}")
