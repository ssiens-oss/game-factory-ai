from fastapi import APIRouter
from pydantic import BaseModel

from game_factory.distributed.safe_queue import enqueue_job
from game_factory.distributed.worker import process_job

router = APIRouter()

class QueueRequest(BaseModel):
    prompt: str


@router.post("/queue/generate")
def queue_generate(data: QueueRequest):

    job = enqueue_job(process_job, data.prompt)

    return {
        "status": "queued_or_executed",
        "job_id": job.id
    }
