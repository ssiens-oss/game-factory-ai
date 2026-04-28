import random

class ExperimentManager:
    def launch(self, spec):
        variants = {}

        for v in ["A", "B", "C"]:
            s = dict(spec)

            if v == "A":
                s["hazard_density"] *= 0.9
            elif v == "B":
                s["hazard_density"] *= 1.0
            else:
                s["hazard_density"] *= 1.2

            variants[v] = s

        return variants
