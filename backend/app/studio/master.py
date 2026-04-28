import redis, json, time, uuid, random
from app.rl.engine import RLEngine

r  = redis.Redis(host="localhost", port=6379, decode_responses=True)
rl = RLEngine()

def generate_job():
    return {
        "id":           str(uuid.uuid4()),
        "difficulty":   rl.difficulty,
        "seed":         random.randint(1, 999999),
        "length":       int(20 + rl.difficulty * 10),
        "hazard_density": min(0.95, 0.2 + rl.difficulty * 0.4),
    }

def loop():
    print("🧠 MASTER ONLINE")
    while True:
        job = generate_job()
        r.lpush("jobs", json.dumps(job))
        print(f"📦 job {job['id'][:8]} | diff={rl.difficulty:.2f}")

        raw = r.lrange("metrics", 0, 50)
        metrics_list = [json.loads(x) for x in raw]
        if metrics_list:
            avg = sum(m.get("reward",0) for m in metrics_list) / len(metrics_list)
            rl.update({"completion_rate": avg, "avg_session_time": 60, "exploit_rate": 0.1})

        time.sleep(3)

if __name__ == "__main__":
    loop()
