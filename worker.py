import redis
import json
import time
import random

r = redis.Redis(host='localhost', port=6379, decode_responses=True)


def compute_reward(job):
    base = random.random()
    return base * job["difficulty"]


def process(job):
    print("🎮 processing", job["id"])

    time.sleep(1)

    reward = compute_reward(job)

    metric = {
        "id": job["id"],
        "reward": reward
    }

    r.lpush("metrics", json.dumps(metric))


def loop():
    print("🤖 WORKER STARTED")

    while True:
        job = r.rpop("jobs")

        if not job:
            time.sleep(1)
            continue

        try:
            job = json.loads(job)
            process(job)

        except Exception as e:
            print("❌ error:", e)


if __name__ == "__main__":
    loop()
