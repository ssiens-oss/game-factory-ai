from game_factory.world.obby.agents.chaser import ChasingHazardAgent
from game_factory.world.obby.agents.predictive import PredictiveTrapAgent
from game_factory.world.obby.agents.adaptive import AdaptiveHazardAgent


class HazardSwarm:

    def __init__(self):
        self.agents = [
            ChasingHazardAgent("chaser"),
            PredictiveTrapAgent("predictor"),
            AdaptiveHazardAgent("director")
        ]

    def step(self, state: dict):
        actions = []

        for agent in self.agents:
            obs = agent.observe(state)
            actions.append(agent.act(obs))

        return actions

    # 🧠 NEW: multi-objective learning update
    def update(self, reward_model):
        for agent in self.agents:
            agent.update(reward_model["scalar"])
