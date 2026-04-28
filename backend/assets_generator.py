import random

def generate_assets(game_type):
    base = {
        "OBBY": ["neon_platform", "lava_block", "jump_pad"],
        "HORROR": ["flickering_light", "blood_decal", "locker_hiding_spot"],
        "PHYSICS": ["ragdoll_dummy", "explosive_barrel", "gravity_zone"],
        "SURVIVAL": ["tree", "rock", "campfire"],
        "TYCOON": ["conveyor_belt", "cash_dropper", "upgrade_terminal"],
        "SIMULATOR": ["pet_spawner", "xp_orb", "collection_zone"],
        "GTA_STYLE": ["car_spawn", "police_npc", "city_prop"]
    }

    assets = base.get(game_type, [])

    return [
        {
            "type": a,
            "seed": random.randint(1, 999999),
            "variation": random.random()
        }
        for a in assets
    ]
