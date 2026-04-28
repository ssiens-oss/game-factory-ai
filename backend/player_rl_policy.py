#!/usr/bin/env python3

from player_state import get_player

def generate_player_diff(player_id):
    state = get_player(player_id)

    diff = {
        "add": [],
        "patch": {}
    }

    # 🎯 PERSONAL DIFFICULTY CURVE
    diff["patch"]["difficulty"] = state["difficulty"]

    # 💰 PERSONAL ECONOMY LAYER
    diff["patch"]["reward_multiplier"] = state["economy_bias"]

    # 🧠 SKILL ADAPTATION
    if state["skill_estimate"] > 1.5:
        diff["add"].append({"type": "hard_platforms"})
    elif state["skill_estimate"] < 0.7:
        diff["add"].append({"type": "assist_platforms"})

    return diff
