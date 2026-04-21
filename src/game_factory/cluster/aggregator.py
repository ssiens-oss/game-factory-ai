class MetricsAggregator:
    """
    Combines worker results into evolution signals.
    """

    def aggregate(self, results):

        exploit = 0
        reward = 0

        for r in results:

            report = r.get("report", {})

            exploit += report.get("exploit_rate", 0)
            reward += report.get("reward", 0)

        n = max(len(results), 1)

        return {
            "avg_exploit": exploit / n,
            "avg_reward": reward / n
        }
