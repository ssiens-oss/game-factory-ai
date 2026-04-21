from game_factory.core.gametype_registry import GameTypeRegistry

from game_factory.world.obby.gametype import ObbyGameType
from game_factory.world.combat.gametype import CombatGameType
from game_factory.world.puzzle.gametype import PuzzleGameType


def register_all():

    GameTypeRegistry.register("obby", ObbyGameType())
    GameTypeRegistry.register("combat", CombatGameType())
    GameTypeRegistry.register("puzzle", PuzzleGameType())
