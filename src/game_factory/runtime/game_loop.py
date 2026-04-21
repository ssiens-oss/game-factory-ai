def build_game_loop(game):

    systems = game.get("systems", [])

    loop = {
        "player": {
            "type": "controller",
            "movement": "run_jump",
            "speed": 6,
            "jump_power": 8
        },

        "systems": {
            "coins": "enabled" if "currency_system" in systems else "disabled",
            "checkpoints": "enabled" if "checkpoint_system" in systems else "disabled",
            "health": "enabled" if "ai_enemies" in systems else "disabled"
        },

        "rules": {
            "win": "reach_finish",
            "lose": "fall_off_map",
            "respawn": "last_checkpoint"
        },

        "ui": {
            "score": "coin_counter",
            "state": "game_over_screen"
        }
    }

    return loop
