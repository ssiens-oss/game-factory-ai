import statistics

def aggregate_playtests(results):
    """
    Takes multiple playtest results and produces a stability + fun ranking.
    """

    scores = [r["fun_score"] for r in results]
    success_rate = sum(1 for r in results if r["success"]) / len(results)

    avg_score = statistics.mean(scores)
    std_dev = statistics.pstdev(scores) if len(scores) > 1 else 0

    stability = max(0, 100 - (std_dev * 2))

    final_score = (avg_score * 0.7) + (success_rate * 100 * 0.3)

    return {
        "average_score": avg_score,
        "success_rate": success_rate,
        "stability": stability,
        "final_score": final_score,
        "risk": classify_risk(std_dev)
    }


def classify_risk(std_dev):
    if std_dev < 5:
        return "stable"
    elif std_dev < 15:
        return "moderate"
    else:
        return "unstable"


def rank_candidates(candidates):
    """
    Sorts generated games by quality score.
    """

    ranked = sorted(
        candidates,
        key=lambda x: x["final_score"],
        reverse=True
    )

    return ranked
