def design_game(intent):

    genre = intent["genre"]
    features = intent["features"]

    loop = {
        "obby": "run → jump → avoid obstacles → reach checkpoint",
        "rpg": "explore → fight → loot → upgrade",
        "shooter": "fight → survive → upgrade"
    }.get(genre, "play → progress → win")

    return {
        "genre": genre,
        "core_loop": loop,
        "systems": features,
        "scenes": ["MainMenu", "Level1"],
        "win_condition": "reach end",
        "fail_condition": "player dies"
    }
