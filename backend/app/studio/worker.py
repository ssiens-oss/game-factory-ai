import redis, json, time, random

r = redis.Redis(host="localhost", port=6379, decode_responses=True)

def process(job):
    reward = random.random() * job.get("difficulty", 1.0)
    r.lpush("metrics", json.dumps({"id": job["id"], "reward": reward}))
    print(f"🤖 done {job['id'][:8]} reward={reward:.2f}")

def loop():
    print("🤖 WORKER ONLINE")
    while True:
        raw = r.rpop("jobs")
        if raw:
            try: process(json.loads(raw))
            except Exception as e: print("err:", e)
        else:
            time.sleep(1)

if __name__ == "__main__":
    loop()
