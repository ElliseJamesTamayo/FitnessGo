from datetime import date

from fastapi import APIRouter

from api_server.db_utils import fetch_one, fetch_all, execute_query

router = APIRouter()


@router.post("/get-active-feedwall-users-today")
def get_active_feedwall_users_today():
    row = fetch_one(
        """
        SELECT COUNT(DISTINCT p.UserId) AS active_feedwall_users
        FROM posts_tb p
        JOIN data_db u ON u.UserId = p.UserId
        WHERE u.AccountStatus = 'Active'
          AND DATE(p.Created_at) = CURDATE()
        """
    )

    return {
        "success": True,
        "data": row.get("active_feedwall_users", 0) if row else 0
    }


@router.post("/get-feedwall-users-today")
def get_feedwall_users_today():
    rows = fetch_all(
        """
        SELECT DISTINCT
               u.UserId AS id,
               u.Fullname AS full_name,
               u.Photo AS photo
        FROM posts_tb p
        JOIN data_db u ON u.UserId = p.UserId
        WHERE u.AccountStatus = 'Active'
          AND DATE(p.Created_at) = CURDATE()
        ORDER BY u.Fullname ASC
        """
    )

    return {
        "success": True,
        "data": rows
    }


@router.post("/auto-deactivate-inactive-accounts")
def auto_deactivate_inactive_accounts():
    result = execute_query(
        """
        UPDATE data_db
        SET AccountStatus = 'Deactivated',
            DeactivationReason = 'inactive',
            Updated_at = NOW()
        WHERE AccountStatus = 'Active'
          AND LastLogin IS NOT NULL
          AND LastLogin < DATE_SUB(NOW(), INTERVAL 365 DAY)
        """
    )

    return {
        "success": result["success"],
        "data": True,
        "rowcount": result["rowcount"]
    }


@router.post("/get-active-accounts")
def get_active_accounts():
    rows = fetch_all(
        """
        SELECT UserId, Fullname, Email, LastLogin
        FROM data_db
        WHERE AccountStatus = 'Active'
        ORDER BY Fullname ASC
        """
    )

    return {
        "success": True,
        "data": rows
    }


@router.post("/get-violator-users")
def get_violator_users():
    rows = fetch_all(
        """
        SELECT UserId, Fullname, Email, ViolationCount
        FROM data_db
        WHERE COALESCE(ViolationCount, 0) > 0
          AND AccountStatus = 'Active'
        ORDER BY ViolationCount DESC, Fullname ASC
        """
    )

    return {
        "success": True,
        "data": rows
    }


@router.post("/get-deactivated-accounts")
def get_deactivated_accounts():
    rows = fetch_all(
        """
        SELECT UserId, Fullname, Email, LastLogin, DeactivationReason
        FROM data_db
        WHERE AccountStatus = 'Deactivated'
        ORDER BY UserId DESC
        """
    )

    return {
        "success": True,
        "data": rows
    }


@router.post("/get-posts-by-user-and-date")
def get_posts_by_user_and_date(payload: dict):
    args = payload.get("args", [])
    user_id = args[0] if len(args) > 0 else None
    selected_date = args[1] if len(args) > 1 else None

    if not selected_date:
        selected_date = date.today().isoformat()

    rows = fetch_all(
        """
        SELECT p.PostId,
               p.UserId,
               p.PostText,
               p.Audience,
               p.PostImage,
               p.IsViolated,
               p.ViolatedAt,
               p.Created_at,
               u.Fullname,
               u.Photo
        FROM posts_tb p
        JOIN data_db u ON u.UserId = p.UserId
        WHERE p.UserId = %s
          AND DATE(p.Created_at) = %s
        ORDER BY p.Created_at DESC
        """,
        (user_id, selected_date)
    )

    return {
        "success": True,
        "data": rows
    }


@router.post("/get-posts-today-by-user")
def get_posts_today_by_user(payload: dict):
    args = payload.get("args", [])
    user_id = args[0] if len(args) > 0 else None

    rows = fetch_all(
        """
        SELECT p.PostId,
               p.UserId,
               p.PostText,
               p.Audience,
               p.PostImage,
               p.IsViolated,
               p.ViolatedAt,
               p.Created_at,
               u.Fullname,
               u.Photo
        FROM posts_tb p
        JOIN data_db u ON u.UserId = p.UserId
        WHERE p.UserId = %s
          AND DATE(p.Created_at) = CURDATE()
          AND u.AccountStatus = 'Active'
        ORDER BY p.Created_at DESC
        """,
        (user_id,)
    )

    return {
        "success": True,
        "data": rows
    }


@router.post("/increment-user-violation")
def increment_user_violation(payload: dict):
    args = payload.get("args", [])
    user_id = args[0] if len(args) > 0 else None

    update_result = execute_query(
        """
        UPDATE data_db
        SET ViolationCount = COALESCE(ViolationCount, 0) + 1,
            Updated_at = NOW()
        WHERE UserId = %s
        LIMIT 1
        """,
        (user_id,)
    )

    row = fetch_one(
        """
        SELECT ViolationCount
        FROM data_db
        WHERE UserId = %s
        LIMIT 1
        """,
        (user_id,)
    )

    violations = row.get("ViolationCount", 0) if row else 0

    if violations >= 5:
        execute_query(
            """
            UPDATE data_db
            SET AccountStatus = 'Deactivated',
                DeactivationReason = 'violation',
                Updated_at = NOW()
            WHERE UserId = %s
            LIMIT 1
            """,
            (user_id,)
        )

    return {
        "success": update_result["success"],
        "data": violations
    }


@router.post("/set-login-notice")
def set_login_notice(payload: dict):
    args = payload.get("args", [])
    user_id = args[0] if len(args) > 0 else None
    notice = args[1] if len(args) > 1 else ""

    result = execute_query(
        """
        UPDATE data_db
        SET LoginNotice = %s,
            ShowLoginNotice = 1,
            Updated_at = NOW()
        WHERE UserId = %s
        LIMIT 1
        """,
        (notice, user_id)
    )

    return {
        "success": result["success"],
        "data": result["success"],
        "rowcount": result["rowcount"]
    }

@router.post("/get-user-violations")
def get_user_violations(payload: dict):
    args = payload.get("args", [])
    user_id = args[0] if len(args) > 0 else None

    row = fetch_one(
        """
        SELECT COALESCE(ViolationCount, 0) AS ViolationCount
        FROM data_db
        WHERE UserId = %s
        LIMIT 1
        """,
        (user_id,)
    )

    violations = row.get("ViolationCount", 0) if row else 0

    return {
        "success": True,
        "data": violations
    }


@router.post("/get-total-violations")
def get_total_violations(payload: dict):
    args = payload.get("args", [])
    user_id = args[0] if len(args) > 0 else None

    row = fetch_one(
        """
        SELECT COALESCE(ViolationCount, 0) AS ViolationCount
        FROM data_db
        WHERE UserId = %s
        LIMIT 1
        """,
        (user_id,)
    )

    violations = row.get("ViolationCount", 0) if row else 0

    return {
        "success": True,
        "data": violations
    }
