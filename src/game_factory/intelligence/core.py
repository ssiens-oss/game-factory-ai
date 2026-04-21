from game_factory.intelligence.evolver import EvolutionEngine

class GameIntelligenceCore:
    """
    Central autonomous system that continuously evolves game designs.
    """

    def __init__(self):
        self.engine = EvolutionEngine()

    def run_cycle(self, seed_prompt: str):
        """
        One full evolution cycle:
        generate → simulate → score → mutate → select
        """

        population = self.engine.generate_population(seed_prompt)

        evaluated = self.engine.evaluate_population(population)

        selected = self.engine.select_best(evaluated)

        mutated = self.engine.mutate(selected)

        return {
            "best_game": selected[0],
            "generation": self.engine.generation,
            "population_size": len(population),
            "score_avg": sum(g["score"] for g in evaluated) / len(evaluated)
        }


    def evolve_continuous(self, seed_prompt: str, cycles: int = 10):
        """
        Fully autonomous loop (self-improving system)
        """

        history = []

        current_seed = seed_prompt

        for _ in range(cycles):

            result = self.run_cycle(current_seed)

            history.append(result)

            # feedback loop: best becomes next seed
            current_seed = result["best_game"]["prompt"]

        return {
            "history": history,
            "final_best": history[-1]["best_game"]
        }
