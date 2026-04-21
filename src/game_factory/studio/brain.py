from game_factory.intelligence.core import GameIntelligenceCore
from game_factory.self_heal.healer import SelfHealingEngine
from game_factory.adversarial.runner import AdversarialRunner

class StudioBrain:
    """
    Central autonomous controller for game factory.
    """

    def __init__(self):

        self.intelligence = GameIntelligenceCore()
        self.healer = SelfHealingEngine()
        self.adversary = AdversarialRunner()

        self.catalog = []

    def run_cycle(self, seed: str):

        # 1. evolve candidate games
        evolution = self.intelligence.evolve_continuous(seed, cycles=1)

        best_game = evolution["final_best"]

        # 2. adversarial stress test
        logs = self.adversary.run(best_game["scene"])

        # 3. self-healing update
        self.healer.train_from_scene(best_game["scene"])

        # 4. publish if good enough
        if evolution["history"][-1]["best_score"] > 70:

            self.catalog.append(best_game)

            return {
                "status": "published",
                "game": best_game
            }

        return {
            "status": "discarded",
            "reason": "insufficient quality"
        }

    def continuous_run(self, seed: str, iterations: int = 100):

        results = []

        for _ in range(iterations):

            result = self.run_cycle(seed)
            results.append(result)

            # feedback loop: system learns from best output
            seed = result.get("game", {}).get("prompt", seed)

        return {
            "runs": results,
            "catalog_size": len(self.catalog)
        }
