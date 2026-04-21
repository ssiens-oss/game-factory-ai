from game_factory.distributed.worker import process_job
from game_factory.intelligence.scoring import score_game
from game_factory.intelligence.mutation import mutate_game

class EvolutionEngine:

    def __init__(self):
        self.generation = 0

    def generate_population(self, prompt: str, size: int = 6):
        return [process_job(prompt) for _ in range(size)]

    def evaluate_population(self, population):
        evaluated = []

        for game in population:
            evaluated.append({
                "game": game,
                "score": score_game(game)
            })

        return evaluated

    def select_best(self, evaluated):
        evaluated.sort(key=lambda x: x["score"], reverse=True)
        return evaluated[:2]

    def mutate(self, selected):
        mutated = []

        for item in selected:
            mutated.append({
                "game": mutate_game(item["game"]),
                "score": 0
            })

        self.generation += 1
        return mutated
