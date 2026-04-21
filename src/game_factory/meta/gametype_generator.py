import random


class MetaGameTypeGenerator:

    def generate(self, seed_context):

        concepts = [
            "timing pressure",
            "resource scarcity",
            "movement precision",
            "risk escalation",
            "hidden information",
            "physics instability",
            "multi-agent competition"
        ]

        core = random.sample(concepts, 3)

        name = f"{core[0]} + {core[1]} system"

        return {
            "name": name,
            "core_loop": core,
            "rules": {
                "pressure": random.random(),
                "complexity": random.random()
            },
            "win_condition": "maximize survival under constraints",
            "failure_conditions": ["timeout", "resource depletion"],
            "reward_model": {
                "efficiency_weight": 0.6,
                "risk_weight": 0.4
            },
            "physics_modifiers": {
                "gravity_scale": random.uniform(0.8, 1.2)
            }
        }
