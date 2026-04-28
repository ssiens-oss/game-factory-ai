#!/usr/bin/env python3

import time, random
from diff_engine import apply_diff

def rl_policy():
    return {
        "add": [
            {
                "type": "platform",
                "pos": [random.randint(0, 50), 5, 0]
            }
        ] if random.random() > 0.5 else [],

        "patch": {
            "difficulty": random.uniform(0.8, 2.5),
            "economy_pressure": random.random()
        }
    }

def loop():
    print("🧠 RL diff engine running")

    while True:
        diff = rl_policy()
        apply_diff(diff)
        time.sleep(2)

if __name__ == "__main__":
    loop()
