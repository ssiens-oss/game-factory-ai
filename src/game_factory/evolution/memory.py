import json
import random

MEMORY_PATH = "data/evolution_memory.json"


def load_memory():
    with open(MEMORY_PATH, "r") as f:
        return json.load(f)


def save_memory(mem):
    with open(MEMORY_PATH, "w") as f:
        json.dump(mem, f, indent=2)


def update_memory(game, metrics):
    """
    Stores successful patterns into long-term memory.
    """

    mem = load_memory()

    mem["stats"]["games_generated"] += 1

    # update running average
    n = mem["stats"]["games_generated"]
    prev = mem["stats"]["avg_fun_score"]

    mem["stats"]["avg_fun_score"] = ((prev * (n - 1)) + metrics["final_score"]) / n

    # store good patterns only
    if metrics["final_score"] > 60:
        mem["best_patterns"].append(extract_pattern(game))

    save_memory(mem)


def extract_pattern(game):
    """
    Converts a scene into a learnable structure pattern.
    """

    return {
        "platform_density": len(game.get("platforms", [])),
        "coin_density": len(game.get("coins", [])),
        "obstacle_density": len(game.get("obstacles", []))
    }


def mutate_from_memory(base_game):
    """
    Uses past success patterns to bias new generation.
    """

    mem = load_memory()

    if not mem["best_patterns"]:
        return base_game

    best = random.choice(mem["best_patterns"])

    mutated = base_game.copy()

    # bias generation toward learned sweet spots
    mutated["target_platform_density"] = best["platform_density"]
    mutated["target_coin_density"] = best["coin_density"]
    mutated["target_obstacle_density"] = best["obstacle_density"]

    return mutated
