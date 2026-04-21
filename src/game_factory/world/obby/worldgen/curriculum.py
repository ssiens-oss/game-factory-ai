import random


class HazardCurriculumEngine:
    """
    Controls hazard complexity based on training stage.
    """

    def __init__(self):
        self.stage = 0  # 0 = beginner, 3 = expert

        self.stages = {
            0: {
                "intensity": 0.1,
                "hazards": [
                    "low_gravity_field",
                    "slippery_surface",
                    "simple_gap"
                ]
            },
            1: {
                "intensity": 0.25,
                "hazards": [
                    "moving_platform_gap",
                    "laser_sweep",
                    "fake_platform"
                ]
            },
            2: {
                "intensity": 0.5,
                "hazards": [
                    "vanishing_platform",
                    "bait_path",
                    "fog_of_war",
                    "teleport_trap"
                ]
            },
            3: {
                "intensity": 0.8,
                "hazards": [
                    "loop_path",
                    "reward_decay_zone",
                    "hazard_inflation_wave",
                    "reverse_gravity_zone",
                    "delayed_state_sync"
                ]
            }
        }

    def update_stage(self, signals: dict):
        """
        Progress curriculum based on performance.
        """

        completion = signals.get("completion_rate", 0.5)
        exploit = signals.get("exploit_rate", 0.5)

        # advance difficulty if success is high
        if completion > 0.75:
            self.stage = min(self.stage + 1, 3)

        # regress if too unstable
        if completion < 0.25:
            self.stage = max(self.stage - 1, 0)

        # exploit-heavy environments accelerate difficulty
        if exploit > 0.7:
            self.stage = min(self.stage + 1, 3)

        return self.stage

    def sample_hazards(self):
        config = self.stages[self.stage]

        return {
            "intensity": config["intensity"],
            "hazards": random.sample(
                config["hazards"],
                k=min(len(config["hazards"]), 3)
            )
        }
