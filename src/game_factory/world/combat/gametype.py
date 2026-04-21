from game_factory.core.base_gametype import BaseGameType
from game_factory.world.combat.engine import CombatArenaEngine


class CombatGameType(BaseGameType):

    def __init__(self):
        self.engine = CombatArenaEngine()

    def generate(self, config):
        return self.engine.generate(config)

    def simulate(self, level):
        return {"combat": "simulated"}

    def evaluate(self, sim_result):
        return sim_result

    def export(self, level):
        return level
