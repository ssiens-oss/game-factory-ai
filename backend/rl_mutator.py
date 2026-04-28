def compute_reward(stats):
    return (
        stats.get("completion_rate", 0) * 2.0 +
        stats.get("avg_time", 0) / 100.0 -
        stats.get("deaths", 0) * 0.01
    )


def mutate(spec, reward):
    if reward > 1.2:
        spec["hazard_density"] *= 1.1
        spec["platform_gap"] *= 0.95

    elif reward < 0.6:
        spec["hazard_density"] *= 0.9
        spec["platform_gap"] *= 1.1

    spec["hazard_density"] = max(0.1, min(0.95, spec["hazard_density"]))
    spec["platform_gap"] = max(2.0, min(8.0, spec["platform_gap"]))

    return spec
