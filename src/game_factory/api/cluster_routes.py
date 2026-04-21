from fastapi import APIRouter
from pydantic import BaseModel

from game_factory.cluster.queue import enqueue, get_result

router = APIRouter()


class JobRequest(BaseModel):
    prompt: str


@router.post("/cluster/submit")
def submit_job(req: JobRequest):
    return enqueue({"prompt": req.prompt})


@router.get("/cluster/result/{job_id}")
def get_job(job_id: str):
    return get_result(job_id)
