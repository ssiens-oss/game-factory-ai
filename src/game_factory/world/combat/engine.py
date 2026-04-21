from game_factory.world.combat.generator import CombatArenaGenerator
from game_factory.world.combat.simulator import CombatSimulator
from game_factory.world.combat.evaluator import CombatEvaluator


class CombatArenaEngine:

    def __init__(self):
        self.generator = CombatArenaGenerator()
        self.simulator = CombatSimulator()
        self.evaluator = CombatEvaluator()

    def generate(self, rules):

        arena = self.generator.generate(rules)

        sim = self.simulator.simulate(arena)

        eval_result = self.evaluator.evaluate(sim)

        arena["metrics"] = eval_result

        return arena
