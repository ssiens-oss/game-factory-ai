import redis
import json
import time
import uuid
import random

r = redis.Redis(host='localhost', port=6379, decode_responses=True)

difficulty = 1.0


def generate_job():
    return {
        "id": str(uuid.uuid4()),
        "difficulty": difficulty,
        "seed": random.randint(1, 999999),
        "length": int(20 + difficulty * 10),
        "hazard_density": min(0.95, 0.2 + difficulty * 0.4),
    }


def push_job(job):
    r.lpush("jobs", json.dumps(job))


def read_metrics():
    data = r.lrange("metrics", 0, 50)
    return [json.loads(x) for x in data]


def update_rl(metrics):
    global difficulty

    if not metrics:
        return

    avg_reward = sum(m["reward"] for m in metrics) / len(metrics)

    if avg_reward > 1.2:
        difficulty *= 1.05
    elif avg_reward < 0.7:
        difficulty *= 0.95

    difficulty = max(0.5, min(3.0, difficulty))


def loop():
    print("🧠 MASTER ONLINE")

    while True:
        job = generate_job()
        push_job(job)

        print("📦 job:", job["id"], "diff:", difficulty)

        metrics = read_metrics()
        update_rl(metrics)

        time.sleep(2)


if __name__ == "__main__":
    loop()
