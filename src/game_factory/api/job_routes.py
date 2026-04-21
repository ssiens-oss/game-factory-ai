from fastapi import APIRouter

from game_factory.runtime.job_store import get_job, list_jobs

router = APIRouter()


@router.get("/jobs/{job_id}")
def get(job_id: str):
    return get_job(job_id)


@router.get("/jobs")
def all_jobs():
    return list_jobs()
