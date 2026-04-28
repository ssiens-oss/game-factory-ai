import os, json

BASE = os.path.expanduser("~/game-factory-ai/backend/storage/global")

def path(pid):
    return os.path.join(BASE, f"{pid}.json")

def load(pid):
    if not os.path.exists(path(pid)):
        return {
            "ltv": 0,
            "sessions": 0,
            "games_played": {},
            "referrals": 0,
            "churn_risk": 0.2,
            "skill": 0.5
        }
    return json.load(open(path(pid)))

def save(pid, data):
    os.makedirs(BASE, exist_ok=True)
    json.dump(data, open(path(pid), "w"))

def update(pid, event):
    d = load(pid)

    d["sessions"] += 1

    game = event.get("game", "obby")
    d["games_played"][game] = d["games_played"].get(game, 0) + 1

    if event["event"] == "purchase":
        d["ltv"] += event.get("value", 0)

    if event["event"] == "referral":
        d["referrals"] += 1

    save(pid, d)
    return d
