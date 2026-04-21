import random
from game_factory.world.obby.agents.hazard_base import BaseHazardAgent


class ChasingHazardAgent(BaseHazardAgent):
    """
    Moves toward agent trajectory (adversarial pursuit).
    """

    def act(self, obs: dict):
        agent_pos = obs["agent_position"]

        return {
            "move_x": agent_pos["x"] + random.uniform(-1, 1),
            "move_y": agent_pos["y"]
        }
