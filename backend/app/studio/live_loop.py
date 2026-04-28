import time, random, json
import redis
from app.rl.economy_brain import EconomyBrain

r    = redis.Redis(host="localhost", port=6379, decode_responses=True)
brain = EconomyBrain()

def loop():
    print("🎮 LIVE RL LOOP ONLINE")
    while True:
        raw = r.lrange("telemetry", 0, 100)
        batch = [json.loads(x) for x in raw]
        state = brain.update(batch)
        print(f"🎚  diff={state['difficulty_curve']:.2f} "
              f"mono={state['monetization_pressure']:.2f}")
        time.sleep(5)

if __name__ == "__main__":
    loop()
