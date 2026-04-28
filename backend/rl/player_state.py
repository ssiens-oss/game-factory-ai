import os, json, time

BASE = os.path.expanduser("~/game-factory-ai/backend/storage/players")

def path(player):
    return os.path.join(BASE, f"{player}.json")

def load(player):
    p = path(player)
    if not os.path.exists(p):
        return {
            "deaths": 0,
            "sessions": 0,
            "spend": 0,
            "skill": 0.5,
            "churn_risk": 0.2
        }
    return json.load(open(p))

def save(player, state):
    os.makedirs(BASE, exist_ok=True)
    json.dump(state, open(path(player), "w"))

def update(player, event):
    s = load(player)

    if event["event"] == "death":
        s["deaths"] += 1

    if event["event"] == "purchase":
        s["spend"] += event.get("value", 0)

    if event["event"] == "session_time":
        s["sessions"] += 1

    save(player, s)
    return s
