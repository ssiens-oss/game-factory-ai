import random
from game_factory.world.obby.worldgen.ai_director import HazardAIDirector
from game_factory.world.obby.worldgen.curriculum import HazardCurriculumEngine


class ObbyHazardGenerator:

    HAZARDS = [
        "vanishing_platform",
        "moving_platform_gap",
        "laser_sweep",
        "fake_platform",
        "fog_of_war",
        "bait_path",
        "teleport_trap",
        "reverse_gravity_zone",
        "loop_path",
        "hazard_inflation_wave"
    ]

    def __init__(self):
        self.director = HazardAIDirector()
        self.curriculum = HazardCurriculumEngine()

    def generate(self, level, signals=None):

        signals = signals or {}

        # 🧠 curriculum decides stage progression
        stage = self.curriculum.update_stage(signals)
        config = self.curriculum.sample_hazards()

        intensity = config["intensity"]

        hazards = []

        for p in level.get("platforms", []):

            if random.random() < intensity:

                hazards.append({
                    "type": random.choice(config["hazards"]),
                    "x": p["x"],
                    "y": p["y"],
                    "severity": intensity,
                    "radius": random.uniform(0.5, 3.5),
                    "stage": stage
                })

        level["hazards"] = hazards
        level["curriculum_stage"] = stage

        return level
