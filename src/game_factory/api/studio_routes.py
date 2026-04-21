from fastapi import APIRouter
from pydantic import BaseModel

from game_factory.studio.orchestrator import run_studio_cycle
from game_factory.studio.loop import run_continuous_factory

router = APIRouter()


class StudioRequest(BaseModel):
    prompt: str


class LoopRequest(BaseModel):
    prompt: str
    cycles: int = 5


@router.post("/studio/run")
def run_once(req: StudioRequest):
    return run_studio_cycle(req.prompt)


@router.post("/studio/loop")
def run_loop(req: LoopRequest):
    return run_continuous_factory(req.prompt, req.cycles)
