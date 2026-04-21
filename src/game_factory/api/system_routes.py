from fastapi import APIRouter
from game_factory.distributed.safe_queue import FALLBACK_MODE

router = APIRouter()

@router.get("/system/status")
def status():

    return {
        "redis_mode": not FALLBACK_MODE,
        "fallback_mode": FALLBACK_MODE,
        "status": "degraded" if FALLBACK_MODE else "healthy"
    }
