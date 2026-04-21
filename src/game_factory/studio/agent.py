import time
from game_factory.studio.idea_engine import IdeaEngine
from game_factory.studio.game_compiler import GameCompiler
from game_factory.studio.playtest_swarm import PlaytestSwarm
from game_factory.studio.evolver import Evolver


class AutonomousStudioAgent:

    def __init__(self):
        self.idea = IdeaEngine()
        self.compiler = GameCompiler()
        self.swarm = PlaytestSwarm()
        self.evolver = Evolver()

        self.catalog = []

    def run_forever(self, iterations=1000):

        for i in range(iterations):

            print(f"\n🎮 Cycle {i}")

            # 1. INVENT
            idea = self.idea.generate()

            # 2. BUILD
            game = self.compiler.compile(idea)

            # 3. TEST
            metrics = self.swarm.run(game)

            # 4. EVOLVE
            game = self.evolver.improve(game, metrics)

            # 5. STORE IF GOOD
            if metrics["avg_success"] > 0.6:
                self.catalog.append(game)
                print("✅ Published game candidate")

            time.sleep(0.1)

        return self.catalog
