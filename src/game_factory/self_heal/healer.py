from game_factory.self_heal.patterns import FailureMemory
from game_factory.self_heal.rules import GenerationRules

from game_factory.adversarial.runner import AdversarialRunner
from game_factory.adversarial.exploits import detect_exploits

class SelfHealingEngine:

    def __init__(self):

        self.memory = FailureMemory()
        self.rules = GenerationRules()
        self.adversary = AdversarialRunner()

    def train_from_scene(self, scene: dict):

        # 1. run adversarial test
        logs = self.adversary.run(scene)

        # 2. detect exploits
        exploits = detect_exploits(logs, scene)

        # 3. record failures
        for e in exploits:
            self.memory.record(e["type"])

        # 4. update rules from failures
        for failure, count in self.memory.dominant_failures():

            if count > 2:
                self.rules.mutate_from_failure(failure)

        return {
            "failures_learned": dict(self.memory.patterns),
            "active_rules": {
                "max_gap_size": self.rules.max_gap_size,
                "coin_density": self.rules.coin_density,
                "allow_vertical_skips": self.rules.allow_vertical_skips
            }
        }

    def generate_healed_scene(self, scene: dict):

        # apply learned constraints before output
        return self.rules.apply(scene)
