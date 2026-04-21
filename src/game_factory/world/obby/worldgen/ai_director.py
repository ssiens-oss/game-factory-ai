import random


class HazardAIDirector:
    """
    Dynamically controls hazard intensity and type distribution
    based on player/agent performance.
    """

    def __init__(self):
        self.intensity = 0.3
        self.stability_target = 0.6

    def update(self, signals: dict):
        """
        Adjust hazard pressure based on ecosystem state.
        """

        exploit = signals.get("exploit_rate", 0.5)
        completion = signals.get("completion_rate", 0.5)
        reward = signals.get("reward", 0.5)

        # too easy → increase difficulty
        if completion > 0.75 and exploit < 0.3:
            self.intensity += 0.05

        # too hard → reduce difficulty
        if completion < 0.3:
            self.intensity -= 0.07

        # exploit-heavy → add chaotic hazards
        if exploit > 0.7:
            self.intensity += 0.03

        # reward collapse → stabilize system
        if reward < 0.2:
            self.intensity -= 0.1

        # clamp
        self.intensity = max(0.05, min(1.0, self.intensity))

        return self.intensity
