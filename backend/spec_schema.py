def generate_spec(difficulty: float, seed: int):
    return {
        "seed": seed,
        "length": int(20 + difficulty * 15),
        "platform_gap": max(2.5, 6.0 - difficulty),
        "hazard_density": min(0.9, 0.2 + difficulty * 0.3),
        "hazards": [
            "lava",
            "spike",
            "moving_platform",
            "rotating_beam",
            "falling_tiles",
            "laser_grid",
            "wind_push",
            "timed_floor"
        ],
        "checkpoint_spacing": max(5, 12 - int(difficulty * 2)),
        "bots": int(25 + difficulty * 60)
    }
