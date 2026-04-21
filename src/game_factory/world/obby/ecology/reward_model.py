class AdaptiveRewardModel:
    """
    Self-modifies reward incentives.
    """

    def __init__(self):
        self.progress_weight = 1.0
        self.completion_bonus = 100
        self.exploit_penalty = 20

    def score(self, progress, completed, exploited):
        reward = progress * self.progress_weight

        if completed:
            reward += self.completion_bonus

        if exploited:
            reward -= self.exploit_penalty

        return reward

    def evolve(self, exploit_rate, triviality_rate):
        """
        Adjust incentives to prevent collapse.
        """

        if exploit_rate > 0.4:
            self.exploit_penalty += 5

        if triviality_rate > 0.5:
            self.progress_weight *= 0.95
            self.completion_bonus += 5
