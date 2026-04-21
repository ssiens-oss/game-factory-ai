from game_factory.core.gametype_registry import GameTypeRegistry


class GameEngine:

    def generate(self, game_type, config):

        handler = GameTypeRegistry.get(game_type)

        level = handler.generate(config)

        sim = handler.simulate(level)

        eval_result = handler.evaluate(sim)

        level["metrics"] = eval_result

        return level
