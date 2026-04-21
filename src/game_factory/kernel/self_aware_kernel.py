import statistics


class SelfAwareEconomicKernel:
    """
    Reflexive economic kernel that observes and modifies itself.
    """

    def __init__(self):
        self.volatility_target = 0.2
        self.liquidity_pressure = 1.0
        self.stability_bias = 0.5

    def introspect(self, prices: list, rewards: list):
        """
        Observe internal system state (like market microstructure).
        """

        volatility = statistics.pstdev(prices) if len(prices) > 1 else 0
        avg_reward = sum(rewards) / max(len(rewards), 1)

        return {
            "volatility": volatility,
            "avg_reward": avg_reward
        }

    def adjust_economic_laws(self, state: dict):
        """
        Self-modifies system parameters based on observed behavior.
        """

        vol = state["volatility"]
        reward = state["avg_reward"]

        # volatility control (market stability mechanism)
        if vol > self.volatility_target:
            self.liquidity_pressure *= 1.1  # inject liquidity
            self.stability_bias += 0.05
        else:
            self.liquidity_pressure *= 0.95

        # reward overheating (bubble detection)
        if reward > 80:
            self.stability_bias += 0.1
            self.volatility_target *= 0.9  # tighten system
        else:
            self.volatility_target *= 1.01  # allow exploration

        # clamp system
        self.stability_bias = min(max(self.stability_bias, 0.1), 1.0)
        self.volatility_target = min(max(self.volatility_target, 0.05), 1.0)

        return {
            "liquidity_pressure": self.liquidity_pressure,
            "stability_bias": self.stability_bias,
            "volatility_target": self.volatility_target
        }
