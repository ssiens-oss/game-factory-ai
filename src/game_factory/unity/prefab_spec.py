def build_prefab_specs(scene):

    specs = []

    # Platforms
    for p in scene.get("platforms", []):
        specs.append({
            "type": "Platform",
            "shape": "cube",
            "position": p,
            "scale": [1, 0.2, 1],
            "tag": "Ground"
        })

    # Coins
    for c in scene.get("coins", []):
        specs.append({
            "type": "Coin",
            "shape": "sphere",
            "position": c,
            "scale": [0.5, 0.5, 0.5],
            "tag": "Collectible"
        })

    # Obstacles
    for o in scene.get("obstacles", []):
        specs.append({
            "type": "Obstacle",
            "shape": "cube",
            "position": o,
            "scale": [1, 1, 1],
            "tag": "Hazard",
            "variant": o.get("type", "block")
        })

    return specs
