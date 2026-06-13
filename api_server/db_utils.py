from datetime import date, datetime
from decimal import Decimal
import base64

from my_connector import auth_tbl


def clean_value(value):
    if isinstance(value, (datetime, date)):
        return value.isoformat()

    if isinstance(value, Decimal):
        return float(value)

    if isinstance(value, bytes):
        return base64.b64encode(value).decode("utf-8")

    return value


def clean_row(row):
    if row is None:
        return None

    return {
        key: clean_value(value)
        for key, value in row.items()
    }


def fetch_one(sql: str, params: tuple = ()):
    cursor = auth_tbl.db.cursor(dictionary=True)
    cursor.execute(sql, params)
    row = cursor.fetchone()
    cursor.close()
    return clean_row(row)


def fetch_all(sql: str, params: tuple = ()):
    cursor = auth_tbl.db.cursor(dictionary=True)
    cursor.execute(sql, params)
    rows = cursor.fetchall()
    cursor.close()
    return [clean_row(row) for row in rows]


def execute_query(sql: str, params: tuple = ()):
    cursor = auth_tbl.db.cursor()
    try:
        cursor.execute(sql, params)
        auth_tbl.db.commit()

        result = {
            "success": True,
            "lastrowid": cursor.lastrowid,
            "rowcount": cursor.rowcount
        }

        cursor.close()
        return result

    except Exception as e:
        auth_tbl.db.rollback()
        cursor.close()

        return {
            "success": False,
            "error": str(e)
        }