from game_factory.studio.idea_engine import IdeaEngine
from game_factory.studio.game_compiler import GameCompiler
from game_factory.studio.playtest_swarm import PlaytestSwarm
from game_factory.studio.evolver import Evolver

from game_factory.market.predictor import PredictiveGameEngine


class MarketDrivenStudioLoop:

    def __init__(self):
        self.idea = IdeaEngine()
        self.compiler = GameCompiler()
        self.swarm = PlaytestSwarm()
        self.evolver = Evolver()

        self.predictor = PredictiveGameEngine()

        self.catalog = []

    def run_cycle(self):

        # 1. INVENT IDEA
        idea = self.idea.generate()

        # 2. BUILD GAME
        game = self.compiler.compile(idea)

        # 3. PREDICT BEFORE PLAYTEST (NEW LAYER)
        prediction = self.predictor.evaluate_game(game)

        decision = prediction["prediction"]["recommendation"]

        print("\n🧠 PREDICTION:", decision)

        # 4. EARLY FILTER (THIS IS KEY)
        if decision == "SKIP":
            print("❌ Skipped before simulation")
            return None

        # 5. SIMULATE ONLY IF WORTH IT
        metrics = self.swarm.run(game)

        # 6. EVOLVE GAME
        game = self.evolver.improve(game, metrics)

        # 7. FINAL FILTER
        if metrics["avg_success"] > 0.65:
            self.catalog.append(game)
            print("✅ Published game candidate")

        return {
            "idea": idea,
            "prediction": prediction,
            "metrics": metrics
        }
