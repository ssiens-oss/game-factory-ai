import random

HAZARDS = [
    "lava_gap","spinning_beam","moving_platform","falling_tiles","crusher",
    "laser_grid","wind_push","ice_slide","teleport_gap","fake_platform",
    "bounce_pad","speed_boost_trap","gravity_flip_zone","rotating_ring",
    "timed_bridge","collapsing_floor","moving_lasers","blade_swing",
    "fire_wave","electric_floor","darkness_zone","memory_platforms",
    "invisible_path","reverse_controls_zone","wind_tunnel","meteor_drop",
    "ice_break_tiles","trap_doors","homing_projectiles","laser_turrets",
    "rolling_boulder","lava_rise_timer","platform_shuffle","gravity_well",
    "laser_crossfire","timed_rotating_blocks","falling_stairs","boss_platform_event",
    "wall_climb_chase","energy_surge_zones","collapsing_bridge_chain","jump_timing_orbs",
    "teleport_maze","moving_spike_floor","speed_zone_switch","fake_checkpoint",
    "invisible_bridge","spike_wall","vertical_climb_spikes","horizontal_spike_wall"
]

GAME_TYPES = ["OBBY","HORROR","PHYSICS","SURVIVAL","TYCOON","SIMULATOR","GTA_STYLE"]

def generate_spec(prompt: str, difficulty: float = 1.0):
    game_type = random.choice(GAME_TYPES)
    seed = random.randint(1, 999999)
    n_hazards = min(len(HAZARDS), max(3, int(difficulty * 6)))
    return {
        "name": f"AutoGame-{seed}",
        "prompt": prompt,
        "gameType": game_type,
        "seed": seed,
        "difficulty": difficulty,
        "length": int(20 + difficulty * 15),
        "platform_gap": max(2.5, 6.0 - difficulty),
        "hazard_density": min(0.9, 0.2 + difficulty * 0.3),
        "hazards": random.sample(HAZARDS, k=n_hazards),
        "checkpoint_spacing": max(5, 12 - int(difficulty * 2)),
        "bots": int(25 + difficulty * 60),
        "monetization": "revive_skip"
    }
