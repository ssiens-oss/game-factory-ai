#!/usr/bin/env python3

import time

PLAYER_STATE = {}

def init_player(player_id):
    if player_id not in PLAYER_STATE:
        PLAYER_STATE[player_id] = {
            "difficulty": 1.0,
            "economy_bias": 1.0,
            "skill_estimate": 0.5,
            "last_seen": time.time()
        }

def update_player(player_id, event):
    init_player(player_id)

    state = PLAYER_STATE[player_id]
    state["last_seen"] = time.time()

    if event["type"] == "death":
        state["difficulty"] *= 0.95
        state["skill_estimate"] *= 0.9

    elif event["type"] == "win":
        state["difficulty"] *= 1.05
        state["skill_estimate"] *= 1.1

    elif event["type"] == "purchase":
        state["economy_bias"] *= 1.2

    # clamp
    state["difficulty"] = max(0.5, min(3.0, state["difficulty"]))
    state["skill_estimate"] = max(0.1, min(3.0, state["skill_estimate"]))

def get_player(player_id):
    init_player(player_id)
    return PLAYER_STATE[player_id]
