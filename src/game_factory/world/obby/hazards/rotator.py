from game_factory.world.obby.hazards.base import Hazard


class RotatingHazard(Hazard):
    """
    Rotates in place, blocking timing-based movement.
    """

    def __init__(self, x, y, speed=1.0):
        super().__init__(x, y)
        self.speed = speed

    def serialize(self):
        data = super().serialize()
        data["speed"] = self.speed
        return data
