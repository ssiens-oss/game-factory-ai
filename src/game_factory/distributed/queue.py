import redis
import json
import uuid

r = redis.Redis(host="redis", port=6379, decode_responses=True)

QUEUE_KEY = "game_jobs"


def enqueue_job(prompt: str):
    job = {
        "id": str(uuid.uuid4()),
        "prompt": prompt,
        "status": "queued"
    }

    r.lpush(QUEUE_KEY, json.dumps(job))
    return job


def get_job():
    raw = r.rpop(QUEUE_KEY)
    if not raw:
        return None
    return json.loads(raw)
