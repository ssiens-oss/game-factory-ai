#!/usr/bin/env python3

import time
import requests
import json

ROBLOX_VM = "http://127.0.0.1:8000/apply"

def generate_diff():
    return {
        "patch": {
            "difficulty": 1.0 + (time.time() % 5) * 0.1,
            "hazard_rate": 0.3 + (time.time() % 3) * 0.05
        },
        "add": [],
        "remove": []
    }

def loop():
    print("🔥 LIVE DIFF STREAM ACTIVE")

    while True:
        diff = generate_diff()

        try:
            requests.post(ROBLOX_VM, json=diff, timeout=1)
        except:
            print("⚠️ Roblox VM unreachable")

        time.sleep(1)

if __name__ == "__main__":
    loop()
