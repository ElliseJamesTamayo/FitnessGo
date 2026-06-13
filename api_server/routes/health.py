from fastapi import APIRouter

router = APIRouter()


@router.get("/")
def health():
    return {
        "status": "online",
        "message": "FitnessGo API Running"
    }