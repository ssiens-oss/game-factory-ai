from game_factory.meta.meta_engine import MetaEngine
from game_factory.core.engine import GameEngine

meta = MetaEngine()
engine = GameEngine()

name = meta.invent_game_type({
    "goal": "fast competitive movement game"
})

print("NEW GAME TYPE:", name)

level = engine.generate(name, {})

print("LEVEL GENERATED:", level)
