from fastapi import APIRouter
from pydantic import BaseModel

from game_factory.evolution.engine import evolve
from game_factory.cluster.queue import enqueue
from game_factory.cluster.queue import get_result

router = APIRouter()


# -------------------------
# START EVOLUTION RUN
# -------------------------
class EvolutionRequest(BaseModel):
    prompt: str
    generations: int = 5
    population: int = 8


@router.post("/control/evolve")
def start_evolution(req: EvolutionRequest):

    result = evolve(
        req.prompt,
        generations=req.generations,
        population_size=req.population
    )

    return {
        "status": "started",
        "best_score": result.get("best_score"),
        "best_game": result.get("best_game")
    }


# -------------------------
# SUBMIT SINGLE MUTATION JOB
# -------------------------
class MutationRequest(BaseModel):
    prompt: str


@router.post("/control/mutate")
def mutate(req: MutationRequest):

    job = enqueue({"prompt": req.prompt})

    return {
        "job_id": job["id"],
        "status": "queued"
    }


# -------------------------
# GET LIVE JOB STATUS
# -------------------------
@router.get("/control/job/{job_id}")
def job_status(job_id: str):

    return get_result(job_id)


# -------------------------
# EMERGENCY RESET (kill bad evolution)
# -------------------------
@router.post("/control/reset")
def reset_system():

    return {
        "status": "reset_triggered",
        "note": "worker queues should be cleared in cluster layer"
    }
