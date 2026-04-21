class MutableWorldRules:
    """
    World mechanics evolve under ecological pressure.
    """

    def __init__(self):
        self.gravity = -9.8
        self.jump_velocity = 12.0
        self.platform_gap_bias = 1.0

    def mutate(self, exploit_rate, completion_rate):

        # too easy -> increase difficulty
        if completion_rate > 0.8:
            self.platform_gap_bias *= 1.1

        # too broken -> reduce exploitability
        if exploit_rate > 0.4:
            self.jump_velocity *= 0.95

    def snapshot(self):
        return {
            "gravity": self.gravity,
            "jump_velocity": self.jump_velocity,
            "gap_bias": self.platform_gap_bias
        }
