import numpy as np


class HazardRewardModel:
    """
    Multi-objective evaluation system for hazard agents.
    """

    def compute(self, report: dict):
        """
        report = outcome of hazard effects on environment + agents
        """

        effectiveness = report.get("failures", 0.0)
        efficiency = report.get("impact_per_change", 0.0)
        diversity = report.get("novelty_score", 0.0)
        adaptivity = report.get("targeting_accuracy", 0.0)
        learning_pressure = report.get("skill_delta", 0.0)

        # 🧠 Pareto-style weighted blend (configurable later)
        reward_vector = np.array([
            effectiveness,
            efficiency,
            diversity,
            adaptivity,
            -abs(learning_pressure)  # too much chaos is bad
        ])

        return {
            "vector": reward_vector,
            "scalar": float(np.mean(reward_vector)),
            "breakdown": {
                "effectiveness": effectiveness,
                "efficiency": efficiency,
                "diversity": diversity,
                "adaptivity": adaptivity,
                "learning_pressure": learning_pressure
            }
        }
