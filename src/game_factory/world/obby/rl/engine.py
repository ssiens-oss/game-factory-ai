from game_factory.world.obby.rl.trainer import ObbyRLSwarmTrainer
from game_factory.world.obby.rl.analyzer import RLEmergenceAnalyzer


class RLOppySwarmEngine:
    """
    Full reinforcement learning obby swarm system.
    """

    def __init__(self):
        self.trainer = ObbyRLSwarmTrainer()
        self.analyzer = RLEmergenceAnalyzer()

    def run(self, level: dict):
        agents = self.trainer.train(level)
        report = self.analyzer.analyze(agents)

        return {
            "agents": agents,
            "analysis": report
        }
