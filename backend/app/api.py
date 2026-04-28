from fastapi import APIRouter
from app.studio.orchestrator import run_cycle

router = APIRouter()

@router.post("/run")
def run(payload: dict):
    prompt = payload.get("prompt", "")
    return run_cycle(prompt)
