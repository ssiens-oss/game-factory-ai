import random


class AdaptivePolicyEngine:
    """
    Self-modifying kernel policy engine.
    Controls how evolution behaves.
    """

    def __init__(self):
        self.mutation_rate = 0.2
        self.reward_bias = 1.0
        self.exploit_sensitivity = 1.0

    def update_from_metrics(self, avg_reward, exploit_rate):
        """
        CORE SELF-MODIFICATION RULES
        """

        # Reward pressure increases exploration
        if avg_reward > 70:
            self.mutation_rate *= 1.1
        else:
            self.mutation_rate *= 0.95

        # Exploit pressure increases defense bias
        if exploit_rate > 60:
            self.exploit_sensitivity *= 1.2
        else:
            self.exploit_sensitivity *= 0.98

        # Clamp system stability
        self.mutation_rate = min(max(self.mutation_rate, 0.05), 0.8)
        self.exploit_sensitivity = min(max(self.exploit_sensitivity, 0.5), 3.0)

    def mutate_prompt(self, base_prompt: str) -> str:
        mutations = [
            "add dynamic obstacles",
            "increase difficulty curve",
            "add risk-reward coins",
            "introduce enemy agents",
            "add physics variability"
        ]

        idx = random.randint(0, len(mutations) - 1)

        return f"{base_prompt} + {mutations[idx]}"
