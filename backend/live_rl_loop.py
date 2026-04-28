#!/usr/bin/env python3

import time
from rl_policy import run_policy
from diff_engine import apply_diff

def loop():
    print("🧠 LIVE RL LOOP ACTIVE")

    while True:
        diff = run_policy()
        apply_diff(diff)
        time.sleep(2)

if __name__ == "__main__":
    loop()
