import redis, json, time, uuid, random

r = redis.Redis(host="localhost", port=6379, decode_responses=True)

difficulty = 1.0


def generate_spec():
    return {
        "id": str(uuid.uuid4()),
        "seed": random.randint(1, 999999),
        "difficulty": difficulty,
        "length": int(25 + difficulty * 10),
        "hazard_density": min(0.95, 0.2 + difficulty * 0.4),
        "bots": int(20 + difficulty * 50)
    }


def push(job):
    r.lpush("jobs", json.dumps(job))


def read_metrics():
    raw = r.lrange("metrics", 0, 200)
    return [json.loads(x) for x in raw]


def update_rl(metrics):
    global difficulty
    if not metrics:
        return

    avg = sum(m.get("reward", 0) for m in metrics) / len(metrics)

    if avg > 1.2:
        difficulty *= 1.05
    elif avg < 0.7:
        difficulty *= 0.95

    difficulty = max(0.5, min(3.0, difficulty))


def loop():
    print("🧠 MASTER ONLINE")

    while True:
        job = generate_spec()
        push(job)

        print("📦 job:", job["id"], "diff:", difficulty)

        update_rl(read_metrics())

        time.sleep(2)


if __name__ == "__main__":
    loop()
