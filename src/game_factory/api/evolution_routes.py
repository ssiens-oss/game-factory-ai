from fastapi import APIRouter
from pydantic import BaseModel

from game_factory.evolution.engine import evolve

router = APIRouter()


class EvolutionRequest(BaseModel):
    prompt: str
    generations: int = 5
    population_size: int = 5


@router.post("/evolve")
def run_evolution(req: EvolutionRequest):

    result = evolve(
        req.prompt,
        generations=req.generations,
        population_size=req.population_size
    )

    return result
