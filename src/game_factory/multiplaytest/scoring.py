def analyze_competition(results: list):

    finished = 0
    failed = 0
    avg_steps = 0

    for r in results:
        log = r["log"]

        if log["finished"]:
            finished += 1
        if log["failed"]:
            failed += 1

        avg_steps += log["steps"]

    n = len(results)

    return {
        "completion_rate": finished / n,
        "failure_rate": failed / n,
        "avg_steps": avg_steps / n,
        "fun_proxy": (finished / n) * 100 - (failed / n) * 50
    }
