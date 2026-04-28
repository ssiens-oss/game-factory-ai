import random

tests = []

def create_variant(game_type):
    return {
        "game_type": game_type,
        "thumbnail_variant": random.randint(1, 5),
        "title_variant": random.randint(1, 5),
        "difficulty_bias": random.uniform(0.8, 1.3)
    }

def score_variant(stats):
    return (
        stats.get("ctr", 0) * 2.0 +
        stats.get("retention", 0) * 3.0 +
        stats.get("playtime", 0) * 0.5 -
        stats.get("bounce_rate", 0) * 2.0
    )

def select_best(variants, stats_list):
    best = None
    best_score = -1

    for v, s in zip(variants, stats_list):
        score = score_variant(s)
        if score > best_score:
            best = v
            best_score = score

    return best
