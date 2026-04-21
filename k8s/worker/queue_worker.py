import redis
import json
import time

from worker import run_job

r = redis.Redis(host="redis", port=6379)

while True:

    job_raw = r.rpop("obby_jobs")

    if not job_raw:
        time.sleep(1)
        continue

    job = json.loads(job_raw)

    result = run_job(job)

    r.lpush("obby_results", json.dumps(result))
