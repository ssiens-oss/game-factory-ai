from game_factory.core.base_gametype import BaseGameType
from game_factory.world.obby.ecology.engine import MetaConsciousGameEcology


class ObbyGameType(BaseGameType):

    def __init__(self):
        self.engine = MetaConsciousGameEcology()

    def generate(self, config):
        return self.engine.evolve(config)

    def simulate(self, level):
        return {"dummy": True}

    def evaluate(self, sim_result):
        return {"score": 1.0}

    def export(self, level):
        return level
