from game_factory.core.gametype_registry import GameTypeRegistry


class GameTypeCompiler:

    def compile(self, spec):

        class DynamicGameType:

            def generate(self, config):
                return {
                    "name": spec["name"],
                    "rules": spec["rules"],
                    "entities": self._build_entities(spec)
                }

            def simulate(self, level):
                return {
                    "stress": spec["rules"]["pressure"]
                }

            def evaluate(self, sim):
                return {
                    "score": sim["stress"]
                }

            def export(self, level):
                return level

            def _build_entities(self, spec):
                return [
                    {"type": "dynamic_object", "value": c}
                    for c in spec["core_loop"]
                ]

        return DynamicGameType()
