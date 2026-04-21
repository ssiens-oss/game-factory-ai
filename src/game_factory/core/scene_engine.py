import random

def build_scene(game_graph):
    """
    Converts a game graph into a playable level layout.
    MVP: grid-based procedural scene definition
    """

    level_length = 25

    scene = {
        "spawn": {"x": 0, "y": 1, "z": 0},
        "finish": {"x": level_length * 2, "y": 1, "z": 0},
        "platforms": [],
        "coins": [],
        "obstacles": [],
        "checkpoints": []
    }

    y = 0

    for i in range(level_length):

        x = i * 2

        # PLATFORM (always exists = path stability)
        scene["platforms"].append({
            "x": x,
            "y": y,
            "z": 0,
            "scale": 1
        })

        # COINS (reward spacing)
        if i % 2 == 0:
            scene["coins"].append({
                "x": x,
                "y": y + 1,
                "z": 0
            })

        # OBSTACLES (difficulty scaling)
        if i % 5 == 0 and i > 0:
            scene["obstacles"].append({
                "x": x,
                "y": y + 1,
                "z": 0,
                "type": random.choice(["block", "spinner", "gap"])
            })

        # CHECKPOINTS
        if i % 10 == 0 and i > 0:
            scene["checkpoints"].append({
                "x": x,
                "y": y + 1,
                "z": 0
            })

    return scene
