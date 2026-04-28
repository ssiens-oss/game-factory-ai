#!/usr/bin/env python3

import requests
import random

API = "http://localhost:8000/events"

def fetch_events():
    try:
        return requests.get(API).json()["events"]
    except:
        return []

def compute_state(events):
    deaths = sum(1 for e in events if e.get("type") == "death")
    wins = sum(1 for e in events if e.get("type") == "win")
    spend = sum(e.get("value", 0) for e in events if e.get("type") == "purchase")

    return {
        "death_rate": deaths,
        "win_rate": wins,
        "economy_pressure": spend
    }

def decide(state):
    # simple RL heuristic (replace later with real model)

    diff = {
        "add": [],
        "patch": {}
    }

    if state["death_rate"] > 5:
        diff["patch"]["difficulty"] = 0.8  # too hard → soften
    elif state["win_rate"] > 10:
        diff["patch"]["difficulty"] = 1.5  # too easy → increase

    if state["economy_pressure"] > 50:
        diff["patch"]["reward_multiplier"] = 0.9
    else:
        diff["patch"]["reward_multiplier"] = 1.1

    return diff

def run_policy():
    events = fetch_events()
    state = compute_state(events)
    return decide(state)

if __name__ == "__main__":
    print(run_policy())
