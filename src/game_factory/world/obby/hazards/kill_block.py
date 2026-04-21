from game_factory.world.obby.hazards.base import Hazard


class KillBlock(Hazard):
    """
    Instant fail object.
    """

    def serialize(self):
        data = super().serialize()
        data["danger"] = 1.0
        return data
