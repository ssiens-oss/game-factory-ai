import requests, time
from collections import defaultdict

EVENTS_API = "http://127.0.0.1:8001/recent"
PATCH_API  = "http://127.0.0.1:8010/apply"

def aggregate(events):
    s = defaultdict(float)
    for e in events:
        if e["event"] == "death":
            s["deaths"] += 1
        if e["event"] == "session_time":
            s["session_time"] += e.get("value", 0)
        if e["event"] == "purchase":
            s["revenue"] += e.get("value", 0)
    return s

def decide(s):
    # simple, stable policy (expand later)
    difficulty = 1.0
    if s["deaths"] > 20: difficulty = 0.9
    elif s["deaths"] < 5: difficulty = 1.2

    revive_price = 1.0
    if s["revenue"] > 5: revive_price = 2.5
    elif s["deaths"] > 10: revive_price = 0.9

    return {"difficulty": round(difficulty, 2), "revive_price": round(revive_price, 2)}

def loop():
    print("🧠 RL brain running")
    while True:
        try:
            events = requests.get(EVENTS_API, timeout=1).json()
            s = aggregate(events)
            patch = decide(s)
            requests.post(PATCH_API, json={"patch": patch}, timeout=1)
            print("🔁 patch:", patch, "| agg:", dict(s))
        except Exception as e:
            print("⚠️ RL loop error:", e)
        time.sleep(3)

if __name__ == "__main__":
    loop()
