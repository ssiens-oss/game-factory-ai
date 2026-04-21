from game_factory.world.obby.hazards.base import Hazard


class MovingPlatform(Hazard):
    """
    Oscillates between two points.
    """

    def __init__(self, x, y, amplitude=3):
        super().__init__(x, y)
        self.amplitude = amplitude

    def serialize(self):
        data = super().serialize()
        data["amplitude"] = self.amplitude
        return data
