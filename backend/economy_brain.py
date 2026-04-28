#!/usr/bin/env python3

from player_segmentation import get_segments

ECONOMY_STATE = {
    "reward_multiplier": 1.0,
    "difficulty_global": 1.0,
    "drop_rate": 1.0
}

def balance(segments):
    """
    RL-style macro optimization
    """

    whales = len(segments["whale"])
    casuals = len(segments["casual"])
    grinders = len(segments["grinder"])

    total = whales + casuals + grinders or 1

    whale_ratio = whales / total

    # 🧠 ECONOMIC CONTROL RULES

    if whale_ratio > 0.2:
        # too many whales → inflate economy pressure
        ECONOMY_STATE["drop_rate"] *= 0.9
        ECONOMY_STATE["reward_multiplier"] *= 0.95

    elif whale_ratio < 0.05:
        # not enough monetization → boost incentives
        ECONOMY_STATE["drop_rate"] *= 1.1
        ECONOMY_STATE["reward_multiplier"] *= 1.2

    # clamp stability
    ECONOMY_STATE["reward_multiplier"] = max(0.5, min(2.0, ECONOMY_STATE["reward_multiplier"]))
    ECONOMY_STATE["drop_rate"] = max(0.5, min(2.0, ECONOMY_STATE["drop_rate"]))

    return ECONOMY_STATE
