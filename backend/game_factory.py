import random

GAME_TYPES = [
    "OBBY",
    "HORROR",
    "PHYSICS",
    "SURVIVAL",
    "TYCOON",
    "SIMULATOR",
    "GTA_STYLE"
]

def generate_game_spec():
    game_type = random.choice(GAME_TYPES)

    return {
        "gameType": game_type,
        "seed": random.randint(1, 999999),
        "difficulty": random.uniform(0.5, 2.0),

        "theme": {
            "HORROR": "dark facility",
            "OBBY": "floating platforms",
            "PHYSICS": "sandbox lab",
            "SURVIVAL": "wild forest",
            "TYCOON": "city builder",
            "SIMULATOR": "collect & upgrade",
            "GTA_STYLE": "open city chaos"
        }[game_type],

        "monetizationModel": {
            "HORROR": "panic_offers",
            "OBBY": "revive_skip",
            "PHYSICS": "cosmetics",
            "SURVIVAL": "boost_survival",
            "TYCOON": "progress_boost",
            "SIMULATOR": "collection_speed",
            "GTA_STYLE": "cosmetics_vehicles"
        }[game_type]
    }
