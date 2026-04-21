import random

class PlayerSimulator:

    def simulate(self, features):

        pressure = features["pressure"]
        complexity = features["complexity"]

        fun = max(0.0, 1.0 - abs(0.5 - pressure))

        retention = fun * (1.0 / (1 + complexity * 0.2))

        virality = (pressure + features["novelty"]) / 2

        return {
            "fun_score": fun,
            "retention": retention,
            "virality": virality
        }
