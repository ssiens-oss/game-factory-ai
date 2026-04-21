import random


class BaseHazardAgent:
    """
    Learned hazard policy (environment adversary).
    """

    def __init__(self, hazard_type: str):
        self.hazard_type = hazard_type
        self.exploit_score = 0.0

    def observe(self, state: dict):
        """
        Perceive agent + environment state.
        """
        return state

    def act(self, obs: dict):
        """
        Decide hazard behavior.
        Must be overridden.
        """
        raise NotImplementedError

    def update(self, reward_signal: float):
        """
        Reinforce hazard effectiveness.
        """
        self.exploit_score += reward_signal * 0.1
