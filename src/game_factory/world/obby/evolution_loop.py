from game_factory.world.obby.engine import AIObbyEngine
from game_factory.world.obby.playtester import ObbyPlaytester
from game_factory.world.obby.evolver import ObbyEvolutionEngine


class ObbyEvolutionLoop:
    """
    Self-improving obby generation system.
    """

    def __init__(self):
        self.engine = AIObbyEngine()
        self.playtester = ObbyPlaytester()
        self.evolver = ObbyEvolutionEngine()

    def run(self, prompt: str, iterations: int = 5):
        result = self.engine.create(prompt)
        level = result["level"]

        for i in range(iterations):
            print(f"\n🧠 iteration {i}")

            stats = self.playtester.run(level)
            print("📊 completion:", stats["avg_completion"])

            level = self.evolver.evolve(level, stats)

        return level
