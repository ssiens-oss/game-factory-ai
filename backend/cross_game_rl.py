global_stats = {}

def update(game_type, metrics):
    if game_type not in global_stats:
        global_stats[game_type] = {
            "revenue": 0,
            "retention": 0,
            "sessions": 0
        }

    g = global_stats[game_type]

    g["revenue"] += metrics.get("revenue", 0)
    g["retention"] += metrics.get("retention", 0)
    g["sessions"] += 1

def best_game_type():
    best = None
    best_score = -1

    for g, m in global_stats.items():
        if m["sessions"] == 0:
            continue

        score = (m["revenue"] * 2 + m["retention"]) / m["sessions"]

        if score > best_score:
            best = g
            best_score = score

    return best
