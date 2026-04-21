from game_factory.world.obby.emulator.simulator import ObbyEmulator
from game_factory.world.obby.emulator.exploit_analyzer import EmulatorExploitAnalyzer


class FullEngineObbyAI:
    """
    Full game-engine-level obby validation system.
    """

    def __init__(self):
        self.sim = ObbyEmulator()
        self.analyzer = EmulatorExploitAnalyzer()

    def evaluate(self, level: dict):
        result = self.sim.run(level)
        analysis = self.analyzer.analyze(result)

        return {
            "simulation_result": result,
            "analysis": analysis
        }
