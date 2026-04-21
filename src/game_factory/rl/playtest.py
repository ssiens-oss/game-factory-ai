import random


def simulate_player(scene):
    """
    Fake agent simulation (upgrade later to real RL agent).
    """

    score = 0

    for coin in scene["coins"]:
        if random.random() > 0.2:
            score += 10

    for obs in scene["obstacles"]:
        if obs["type"] == "block":
            score -= 5

    difficulty_penalty = len(scene["obstacles"]) * 2

    return {
        "fun_score": score - difficulty_penalty,
        "completion_rate": random.uniform(0.4, 1.0)
    }
