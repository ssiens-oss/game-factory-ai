import random

class MechanicGenerator:

    def generate(self):

        mechanics = [
            "gravity inversion timing",
            "resource decay pressure",
            "path visibility flicker",
            "movement cost escalation",
            "risk-reward teleport loops",
            "dynamic platform collapse",
            "time delayed input execution"
        ]

        core = random.sample(mechanics, 3)

        return {
            "name": f"{core[0]} + {core[1]} system",
            "core_mechanics": core,
            "interaction_model": "emergent",
            "difficulty_bias": random.uniform(0.3, 0.9)
        }
