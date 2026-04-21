import time
import uuid

# GLOBAL SINGLETON STORAGE (attached to module object itself)
_STORE = {
    "jobs": {}
}


def create_job(prompt: str):
    job_id = str(uuid.uuid4())

    job = {
        "id": job_id,
        "prompt": prompt,
        "status": "queued",
        "progress": 0,
        "result": None,
        "error": None,
        "created_at": time.time(),
        "updated_at": time.time()
    }

    _STORE["jobs"][job_id] = job
    return job


def update_job(job_id: str, **kwargs):
    job = _STORE["jobs"].get(job_id)
    if not job:
        return

    job.update(kwargs)
    job["updated_at"] = time.time()


def get_job(job_id: str):
    return _STORE["jobs"].get(job_id)


def list_jobs():
    return list(_STORE["jobs"].values())
