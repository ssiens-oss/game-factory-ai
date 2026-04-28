def evaluate(metrics):
    score = (
        metrics["completion_rate"] * 0.4 +
        metrics["avg_session_time"] / 600 * 0.3 -
        metrics["exploit_rate"] * 0.2
    )
    return {"score": score, "approved": score > 0.5}
