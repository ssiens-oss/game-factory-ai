def score_trends(videos):
    score = {
        "fear": 0,
        "curiosity": 0,
        "challenge": 0,
        "power_fantasy": 0
    }

    for v in videos:
        t = v["title"].lower()

        if "scary" in t or "horror" in t:
            score["fear"] += 1

        if "secret" in t or "hidden" in t:
            score["curiosity"] += 1

        if "challenge" in t or "hard" in t:
            score["challenge"] += 1

        if "overpowered" in t or "god mode" in t:
            score["power_fantasy"] += 1

    # normalize
    total = max(1, sum(score.values()))
    return {k: v / total for k, v in score.items()}
