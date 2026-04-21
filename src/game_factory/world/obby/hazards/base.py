class Hazard:
    """
    Base hazard object.
    """

    def __init__(self, x, y, z=0):
        self.x = x
        self.y = y
        self.z = z

    def serialize(self):
        return {
            "type": self.__class__.__name__,
            "x": self.x,
            "y": self.y,
            "z": self.z
        }
