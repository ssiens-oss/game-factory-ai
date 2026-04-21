def parse_intent(prompt: str):

    p = prompt.lower()

    genre = "unknown"
    if "obby" in p or "parkour" in p:
        genre = "obby"
    elif "rpg" in p:
        genre = "rpg"
    elif "shooter" in p:
        genre = "shooter"

    features = []

    if "coins" in p:
        features.append("currency_system")
    if "checkpoints" in p:
        features.append("checkpoint_system")
    if "enemies" in p:
        features.append("ai_enemies")

    return {
        "raw": prompt,
        "genre": genre,
        "features": features
    }
