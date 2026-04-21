from game_factory.world.obby.rl.conscious_trainer import SwarmConsciousTrainer
from game_factory.world.obby.rl.conscious_analyzer import SwarmConsciousAnalyzer


class SwarmConsciousEngine:
    """
    Fully shared swarm intelligence system.
    """

    def __init__(self):
        self.trainer = SwarmConsciousTrainer()
        self.analyzer = SwarmConsciousAnalyzer()

    def run(self, level: dict):
        agents = self.trainer.train(level)
        report = self.analyzer.analyze(
            agents,
            self.trainer.env.memory
        )

        return {
            "agents": agents,
            "analysis": report
        }
