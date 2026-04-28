#!/usr/bin/env python3

from player_state import PLAYER_STATE

def classify(player_id, state):
    """
    Simple RL segmentation heuristic (replace later with model)
    """

    skill = state["skill_estimate"]
    econ = state["economy_bias"]
    difficulty = state["difficulty"]

    # 🐋 whales: high spending / high engagement pressure
    if econ > 1.5:
        return "whale"

    # 🏃 grinders: high skill, low spending, high engagement
    if skill > 1.3 and econ < 1.2:
        return "grinder"

    # 🎯 casuals: baseline users
    return "casual"


def get_segments():
    segments = {"whale": [], "casual": [], "grinder": []}

    for pid, state in PLAYER_STATE.items():
        seg = classify(pid, state)
        segments[seg].append(pid)

    return segments
