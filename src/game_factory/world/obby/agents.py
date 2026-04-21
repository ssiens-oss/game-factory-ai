import random


class ObbyBot:
    """
    Simulated player for obby testing.
    """

    def __init__(self, skill: float = 1.0):
        self.skill = skill
        self.position = 0

    def attempt_jump(self, difficulty: float):
        """
        Returns True if jump succeeds.
        """
        chance = self.skill - difficulty + random.uniform(-0.1, 0.1)
        return chance > 0.5

    def run_level(self, level: dict):
        failures = 0

        for i, p in enumerate(level["platforms"]):
            difficulty = p.get("gap_multiplier", 1.0)

            if not self.attempt_jump(difficulty):
                failures += 1

        return {
            "failures": failures,
            "completion_rate": 1 - failures / max(len(level["platforms"]), 1)
        }
