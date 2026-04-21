from game_factory.evolution.genome import create_genome, mutate_genome
from game_factory.evolution.decoder import genome_to_scene
from game_factory.distributed.worker import process_job


def fitness(evaluation):
    return evaluation.get("fun_score", -100)


def evolve(prompt, generations=5, population_size=6):

    population = []

    # INIT POPULATION (genomes, not scenes)
    for _ in range(population_size):
        genome = create_genome()
        population.append(genome)

    best = None
    best_score = -999

    for gen in range(generations):

        print(f"🧬 Generation {gen+1}")

        scored = []

        for genome in population:

            scene = genome_to_scene(genome)

            # inject scene into process pipeline
            result = process_job(prompt)

            score = fitness(result["evaluation"])

            scored.append((score, genome, result))

            if score > best_score:
                best_score = score
                best = result

        # SORT BY FITNESS
        scored.sort(key=lambda x: x[0], reverse=True)

        top_half = [g for _, g, _ in scored[: max(2, population_size // 2)]]

        # MUTATE NEW GENERATION
        new_population = []

        for g in top_half:
            new_population.append(g)
            new_population.append(mutate_genome(g))

        population = new_population[:population_size]

        print(f"🏆 Best score: {best_score}")

    return {
        "best_game": best,
        "best_score": best_score
    }
