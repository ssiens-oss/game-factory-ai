import random

class IdeaEngine:

    def generate(self):

        themes = [
            "time pressure",
            "resource scarcity",
            "movement mastery",
            "risk navigation",
            "deception mechanics",
            "physics instability",
            "multi-agent competition"
        ]

        core = random.sample(themes, 3)

        return {
            "title": f"{core[0]} + {core[1]} prototype",
            "core_loop": core,
            "intent": "emergent gameplay discovery",
            "complexity_target": random.uniform(0.4, 0.9)
        }
