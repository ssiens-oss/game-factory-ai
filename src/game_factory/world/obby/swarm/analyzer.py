class SwarmAnalyzer:
    """
    Evaluates emergent behavior from swarm runs.
    """

    def analyze(self, swarm_result: dict):

        finishers = swarm_result["finish_count"]
        exploits = swarm_result["exploit_memory"]

        risk_score = 0

        if "skip_trick" in exploits:
            risk_score += 0.7

        if finishers > 5:
            risk_score += 0.3

        return {
            "finishers": finishers,
            "exploit_risk": risk_score,
            "meta_state": "broken" if risk_score > 0.8 else "stable"
        }
