from ab_tracker import best_variant
import random


def compute_reward(metrics):
    return (
        metrics.get("completion_rate", 0) * 1.5 +
        metrics.get("retention", 0) * 2.0 +
        metrics.get("avg_session", 0) / 100
    )


def update_policy(global_state):
    best = best_variant()

    if best == "A":
        global_state["bias"] = 0.9
    elif best == "B":
        global_state["bias"] = 1.0
    elif best == "C":
        global_state["bias"] = 1.2

    return global_state
