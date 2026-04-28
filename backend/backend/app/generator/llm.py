def generate_spec(prompt: str):
    return {
        "name": "AutoGame",
        "genre": "obby",
        "prompt": prompt,
        "mechanics": ["jump", "avoid_lava", "checkpoint"]
    }
