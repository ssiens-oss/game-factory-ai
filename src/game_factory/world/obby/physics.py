import math


class ObbyPhysics:
    """
    Simplified movement physics model for obby traversal.
    """

    def __init__(self):
        self.gravity = -9.8
        self.jump_velocity = 12.0
        self.run_speed = 6.0

    def time_to_fall(self, height_diff: float):
        if height_diff >= 0:
            return 0
        return math.sqrt((2 * abs(height_diff)) / abs(self.gravity))

    def horizontal_reach(self, airtime: float):
        return self.run_speed * airtime

    def can_reach(self, dx: float, dy: float):
        airtime = self.time_to_fall(dy)
        reach = self.horizontal_reach(airtime)
        return reach >= abs(dx)
