import random

def create_genome():
    return {
        "platform_spacing": random.uniform(1.5, 4.0),
        "coin_density": random.uniform(0.2, 1.0),
        "obstacle_rate": random.uniform(0.1, 0.6),
        "gap_frequency": random.uniform(0.0, 0.4),
        "difficulty_ramp": random.uniform(0.5, 2.0),
        "length": random.randint(20, 60)
    }


def mutate_genome(genome, strength=0.2):
    """Deep param-level mutation (NOT structural)."""

    g = genome.copy()

    def jitter(value, scale):
        return max(0.05, value + random.uniform(-scale, scale))

    g["platform_spacing"] = jitter(g["platform_spacing"], strength)
    g["coin_density"] = jitter(g["coin_density"], strength)
    g["obstacle_rate"] = jitter(g["obstacle_rate"], strength)
    g["gap_frequency"] = jitter(g["gap_frequency"], strength)
    g["difficulty_ramp"] = jitter(g["difficulty_ramp"], strength * 2)

    # structural mutation (length is key evolutionary pressure)
    if random.random() < 0.3:
        g["length"] = max(10, g["length"] + random.randint(-10, 10))

    return g
