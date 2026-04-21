from fastapi import FastAPI
import redis
import json
import uuid

app = FastAPI()
r = redis.Redis(host="redis", port=6379)


@app.post("/submit")
def submit_job(level: dict):

    job_id = str(uuid.uuid4())

    job = {
        "id": job_id,
        "level": level
    }

    r.lpush("obby_jobs", json.dumps(job))

    return {"job_id": job_id}
