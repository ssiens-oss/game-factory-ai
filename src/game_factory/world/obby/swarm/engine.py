from game_factory.world.obby.swarm.simulator import SwarmSimulator
from game_factory.world.obby.swarm.analyzer import SwarmAnalyzer


class ObbySwarmEngine:
    """
    Multi-agent competitive obby stress test system.
    """

    def __init__(self, agents: int = 20):
        self.sim = SwarmSimulator(agent_count=agents)
        self.analyzer = SwarmAnalyzer()

    def evaluate(self, level: dict):
        swarm_result = self.sim.run(level)
        analysis = self.analyzer.analyze(swarm_result)

        return {
            "swarm": swarm_result,
            "analysis": analysis
        }
