import random
from game_factory.world.obby.agents.hazard_base import BaseHazardAgent


class PredictiveTrapAgent(BaseHazardAgent):
    """
    Learns common agent paths and blocks them.
    """

    def act(self, obs: dict):
        path_history = obs.get("agent_path", [])

        if len(path_history) > 2:
            last = path_history[-1]

            return {
                "block_x": last["x"],
                "block_y": last["y"]
            }

        return {"idle": True}
