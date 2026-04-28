import random

def generate_thumbnail(game_type):
    hooks = {
        "OBBY": "Impossible Neon Tower",
        "HORROR": "You Are Not Alone",
        "PHYSICS": "Chaos Simulator",
        "SURVIVAL": "Last Night in the Forest",
        "TYCOON": "Start From Nothing",
        "SIMULATOR": "Become Overpowered Fast",
        "GTA_STYLE": "Break Every Rule"
    }

    return {
        "title": hooks.get(game_type, "New Experience"),
        "visual_seed": random.randint(1, 999999),
        "style": game_type.lower(),
        "emotion_target": "curiosity + urgency"
    }
