import random
import math

# arms = pricing options
ARMS = [0.99, 1.99, 2.99]

STATE = {str(a): {"reward": 0, "trials": 0} for a in ARMS}

def select_arm():
    total = sum(v["trials"] for v in STATE.values()) + 1

    best = None
    best_score = -1

    for arm, data in STATE.items():
        if data["trials"] == 0:
            return float(arm)

        avg = data["reward"] / data["trials"]
        bonus = math.sqrt(2 * math.log(total) / data["trials"])
        score = avg + bonus

        if score > best_score:
            best_score = score
            best = arm

    return float(best)

def update(arm, reward):
    s = STATE[str(arm)]
    s["trials"] += 1
    s["reward"] += reward
