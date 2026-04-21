from game_factory.world.obby.agents.hazard_base import BaseHazardAgent


class AdaptiveHazardAgent(BaseHazardAgent):
    """
    Adjusts hazard intensity dynamically.
    """

    def act(self, obs: dict):
        success_rate = obs.get("success_rate", 0.5)

        if success_rate > 0.7:
            return {"intensify": 1.2}

        if success_rate < 0.3:
            return {"intensify": 0.5}

        return {"intensify": 1.0}
