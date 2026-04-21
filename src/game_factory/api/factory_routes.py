from fastapi import APIRouter
from pydantic import BaseModel

from game_factory.factory.loop import run_factory

router = APIRouter()

class FactoryPrompt(BaseModel):
    prompt: str
    iterations: int = 5
    playtests_per_scene: int = 5

@router.post("/factory/run")
def run(data: FactoryPrompt):

    result = run_factory(
        data.prompt,
        data.iterations,
        data.playtests_per_scene
    )

    return {
        "status": "completed",
        "best_metrics": result["best_metrics"],
        "best_scene": result["best_scene"],
        "ranking_summary": [
            {
                "score": r["metrics"]["final_score"],
                "stability": r["metrics"]["stability"]
            }
            for r in result["ranking"]
        ]
    }
