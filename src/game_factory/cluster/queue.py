import time
import uuid

try:
    import redis
    REDIS_AVAILABLE = True
except:
    REDIS_AVAILABLE = False


# -------------------------
# MEMORY FALLBACK QUEUE
# -------------------------
_MEMORY_QUEUE = []
_RESULTS = {}


def enqueue(job):
    job_id = str(uuid.uuid4())

    payload = {
        "id": job_id,
        "prompt": job["prompt"],
        "status": "queued",
        "created_at": time.time()
    }

    _MEMORY_QUEUE.append(payload)

    return payload


def dequeue():
    if not _MEMORY_QUEUE:
        return None
    return _MEMORY_QUEUE.pop(0)


def save_result(job_id, result):
    _RESULTS[job_id] = result


def get_result(job_id):
    return _RESULTS.get(job_id)


def list_jobs():
    return _MEMORY_QUEUE
