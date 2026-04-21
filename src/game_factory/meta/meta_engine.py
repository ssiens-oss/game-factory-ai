from game_factory.meta.gametype_generator import MetaGameTypeGenerator
from game_factory.meta.compiler import GameTypeCompiler
from game_factory.core.gametype_registry import GameTypeRegistry


class MetaEngine:

    def __init__(self):
        self.generator = MetaGameTypeGenerator()
        self.compiler = GameTypeCompiler()

    def invent_game_type(self, context):

        spec = self.generator.generate(context)

        game_type = self.compiler.compile(spec)

        GameTypeRegistry.register(spec["name"], game_type)

        return spec["name"]
