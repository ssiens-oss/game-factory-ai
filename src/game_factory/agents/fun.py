def fun_agent(game: dict):
    base = len(game["game"]) % 80
    return {
        "fun_score": base + 20
    }
