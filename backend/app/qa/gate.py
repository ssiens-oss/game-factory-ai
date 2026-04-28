def evaluate(metrics):
    score = (
        metrics["completion_rate"]    * 0.5 +
        metrics["avg_session_time"] / 600 * 0.4 -
        metrics["exploit_rate"]       * 0.1
    )
    return {"score": round(score, 4), "approved": score > 0.35}
