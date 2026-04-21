def genome_to_scene(genome):
    platforms = []
    coins = []
    obstacles = []

    x = 0

    for i in range(genome["length"]):

        # PLATFORM
        platforms.append({
            "x": x,
            "y": 0,
            "z": 0,
            "scale": 1
        })

        # COINS
        if i % max(1, int(1 / genome["coin_density"])) == 0:
            coins.append({"x": x, "y": 1, "z": 0})

        # OBSTACLES
        if i % max(1, int(1 / genome["obstacle_rate"])) == 0:
            obstacles.append({
                "x": x,
                "y": 1,
                "z": 0,
                "type": "block"
            })

        # GAP INSERTION
        if genome["gap_frequency"] > 0.3 and i % 10 == 0:
            x += genome["platform_spacing"] * 2
        else:
            x += genome["platform_spacing"]

    return {
        "spawn": {"x": 0, "y": 1, "z": 0},
        "finish": {"x": x, "y": 1, "z": 0},
        "platforms": platforms,
        "coins": coins,
        "obstacles": obstacles,
        "checkpoints": [
            {"x": x * 0.5, "y": 1, "z": 0}
        ]
    }
