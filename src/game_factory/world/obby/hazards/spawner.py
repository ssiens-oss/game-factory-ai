import random

from game_factory.world.obby.hazards.kill_block import KillBlock
from game_factory.world.obby.hazards.moving_platform import MovingPlatform
from game_factory.world.obby.hazards.rotator import RotatingHazard


class HazardSpawner:
    """
    Spawns hazards based on ecological difficulty pressure.
    """

    def spawn(self, platforms, difficulty: float):

        hazards = []

        for p in platforms:

            x = p["x"]
            y = p["y"]

            # increasing difficulty = more hazards
            roll = random.random() * difficulty

            if roll > 0.8:
                hazards.append(KillBlock(x, y + 1))

            elif roll > 0.6:
                hazards.append(MovingPlatform(x, y + 1))

            elif roll > 0.4:
                hazards.append(RotatingHazard(x, y + 1))

        return [h.serialize() for h in hazards]
