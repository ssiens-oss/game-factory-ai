from game_factory.meta.autonomous_designer import AutonomousGameDesigner
from game_factory.meta.playtest_swarm import PlaytestSwarm
from game_factory.meta.evolution_core import EvolutionCore


class AutonomousGameSystem:

    def __init__(self):
        self.designer = AutonomousGameDesigner()
        self.swarm = PlaytestSwarm()
        self.evolver = EvolutionCore()

    def run_cycle(self):

        game = self.designer.design_game()

        results = self.swarm.simulate(game)

        evolved = self.evolver.evolve(game, results)

        return {
            "game": evolved,
            "metrics": results
        }
