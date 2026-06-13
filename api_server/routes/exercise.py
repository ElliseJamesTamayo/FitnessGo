from fastapi import APIRouter, HTTPException

from api_server.schemas.exercise_schema import (
    UserExerciseCreate,
    UserExerciseUpdate,
    SavedExerciseCreate
)
from api_server.db_utils import fetch_one, fetch_all, execute_query

router = APIRouter()


@router.get("/user/{user_id}")
def get_user_exercises(user_id: int):
    rows = fetch_all(
        """
        SELECT UserExerciseId, UserId, Goal, Category, Name,
               Meaning, Steps, Benefits, Difficulty, ProgramName,
               Sets, Reps, RestSeconds, Created_at, Updated_at,
               Mode, IsDeleted
        FROM user_exercises
        WHERE UserId = %s
          AND COALESCE(IsDeleted, 0) = 0
        ORDER BY Created_at DESC
        """,
        (user_id,)
    )

    return {
        "success": True,
        "exercises": rows
    }


@router.get("/{exercise_id}")
def get_exercise(exercise_id: int):
    row = fetch_one(
        """
        SELECT UserExerciseId, UserId, Goal, Category, Name,
               Meaning, Steps, Benefits, Difficulty, ProgramName,
               Sets, Reps, RestSeconds, Created_at, Updated_at,
               Mode, IsDeleted
        FROM user_exercises
        WHERE UserExerciseId = %s
        LIMIT 1
        """,
        (exercise_id,)
    )

    if not row:
        raise HTTPException(
            status_code=404,
            detail="Exercise not found"
        )

    return row


@router.post("/")
def create_user_exercise(payload: UserExerciseCreate):
    result = execute_query(
        """
        INSERT INTO user_exercises
        (UserId, Goal, Category, Name, Meaning, Steps, Benefits,
         Difficulty, ProgramName, Sets, Reps, RestSeconds,
         Created_at, Updated_at, Mode, IsDeleted)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                NOW(), NOW(), %s, 0)
        """,
        (
            payload.UserId,
            payload.Goal,
            payload.Category,
            payload.Name,
            payload.Meaning,
            payload.Steps,
            payload.Benefits,
            payload.Difficulty,
            payload.ProgramName,
            payload.Sets,
            payload.Reps,
            payload.RestSeconds,
            payload.Mode
        )
    )

    if not result["success"]:
        raise HTTPException(
            status_code=400,
            detail=result["error"]
        )

    return {
        "success": True,
        "UserExerciseId": result["lastrowid"]
    }


@router.put("/{exercise_id}")
def update_user_exercise(exercise_id: int, payload: UserExerciseUpdate):
    result = execute_query(
        """
        UPDATE user_exercises
        SET Goal=%s,
            Category=%s,
            Name=%s,
            Meaning=%s,
            Steps=%s,
            Benefits=%s,
            Difficulty=%s,
            ProgramName=%s,
            Sets=%s,
            Reps=%s,
            RestSeconds=%s,
            Mode=%s,
            Updated_at=NOW()
        WHERE UserExerciseId=%s
        LIMIT 1
        """,
        (
            payload.Goal,
            payload.Category,
            payload.Name,
            payload.Meaning,
            payload.Steps,
            payload.Benefits,
            payload.Difficulty,
            payload.ProgramName,
            payload.Sets,
            payload.Reps,
            payload.RestSeconds,
            payload.Mode,
            exercise_id
        )
    )

    return {
        "success": result["success"],
        "rowcount": result["rowcount"]
    }


@router.delete("/{exercise_id}")
def delete_user_exercise(exercise_id: int):
    result = execute_query(
        """
        UPDATE user_exercises
        SET IsDeleted = 1,
            Updated_at = NOW()
        WHERE UserExerciseId = %s
        LIMIT 1
        """,
        (exercise_id,)
    )

    return {
        "success": result["success"],
        "rowcount": result["rowcount"]
    }


@router.get("/saved/user/{user_id}")
def get_saved_exercises(user_id: int):
    rows = fetch_all(
        """
        SELECT SavedExerciseByUserId, UserId, UserExerciseId,
               name, difficulty, program_name, sets, reps,
               rest_seconds, created_at, updated_at
        FROM saved_exercises_by_user
        WHERE UserId = %s
        ORDER BY created_at DESC
        """,
        (user_id,)
    )

    return {
        "success": True,
        "saved_exercises": rows
    }


@router.post("/saved")
def save_exercise(payload: SavedExerciseCreate):
    result = execute_query(
        """
        INSERT INTO saved_exercises_by_user
        (UserId, UserExerciseId, name, difficulty, program_name,
         sets, reps, rest_seconds, created_at, updated_at)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, NOW(), NOW())
        """,
        (
            payload.UserId,
            payload.UserExerciseId,
            payload.name,
            payload.difficulty,
            payload.program_name,
            payload.sets,
            payload.reps,
            payload.rest_seconds
        )
    )

    if not result["success"]:
        raise HTTPException(
            status_code=400,
            detail=result["error"]
        )

    return {
        "success": True,
        "SavedExerciseByUserId": result["lastrowid"]
    }


@router.delete("/saved/{saved_exercise_id}")
def delete_saved_exercise(saved_exercise_id: int):
    result = execute_query(
        """
        DELETE FROM saved_exercises_by_user
        WHERE SavedExerciseByUserId = %s
        LIMIT 1
        """,
        (saved_exercise_id,)
    )

    return {
        "success": result["success"],
        "rowcount": result["rowcount"]
    }