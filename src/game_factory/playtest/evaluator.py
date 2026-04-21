def evaluate_playtest(result: dict):
    log = result["log"]

    score = 0

    # completion reward
    if log["finished"]:
        score += 100
    else:
        score -= 50

    # failure penalty
    if log["failed"]:
        score -= 30

    # speed reward
    score += max(0, 50 - log["steps"])

    # engagement proxy (movement = exploration)
    score += log["steps"] * 0.5

    return {
        "score": score,
        "finished": log["finished"],
        "failed": log["failed"]
    }
