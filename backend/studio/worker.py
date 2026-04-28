import redis, json, time, random

r = redis.Redis(host="localhost", port=6379, decode_responses=True)


def reward(job):
    return random.random() * job.get("difficulty", 1.0)


def process(job):
    r.lpush("metrics", json.dumps({
        "id": job["id"],
        "reward": reward(job)
    }))


def loop():
    print("🤖 WORKER ONLINE")

    while True:
        job = r.rpop("jobs")

        if not job:
            time.sleep(1)
            continue

        try:
            process(json.loads(job))
        except Exception as e:
            print("error:", e)


if __name__ == "__main__":
    loop()
