from game_factory.agents.builder import builder_agent
from game_factory.agents.exploit import exploit_agent
from game_factory.agents.fun import fun_agent
from game_factory.agents.referee import referee_agent
from game_factory.agents.optimizer import optimizer_agent


class GameKernel:
    """
    Autonomous Game OS Kernel:
    decides what games should exist and evolve.
    """

    def __init__(self):
        self.iteration = 0
        self.global_reward = 0

    def evaluate(self, game):
        exploit = exploit_agent(game)
        fun = fun_agent(game)

        decision = referee_agent(fun["fun_score"], exploit["exploit_score"])

        return fun, exploit, decision

    def step(self, prompt: str):
        self.iteration += 1

        game = builder_agent(prompt)
        fun, exploit, decision = self.evaluate(game)

        if decision["accept"]:
            self.global_reward += decision["reward"]
            return {
                "status": "accepted",
                "game": game,
                "reward": decision["reward"]
            }

        return {
            "status": "rejected",
            "prompt": optimizer_agent(prompt, exploit)
        }
