class EcologyObserver:
    """
    Measures population-world dynamics.
    """

    def analyze(self, swarm_report):

        finishers = swarm_report["analysis"]["finishers"]

        exploit_rate = (
            swarm_report["analysis"]["shared_experience_size"] / 5000
        )

        completion_rate = finishers / 10

        triviality_rate = max(
            0,
            completion_rate - 0.8
        )

        return {
            "exploit_rate": exploit_rate,
            "completion_rate": completion_rate,
            "triviality_rate": triviality_rate
        }
