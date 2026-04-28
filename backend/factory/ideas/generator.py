import random

BASE_THEMES = [
    "obby escape",
    "horror survival",
    "tycoon empire",
    "physics chaos simulator",
    "trap parkour",
    "escape prison",
    "infinite runner"
]

def generate_idea(trend_signal=1.0):

    theme = random.choice(BASE_THEMES)

    modifiers = []

    if trend_signal > 0.7:
        modifiers.append("viral mechanics")
    if trend_signal < 0.3:
        modifiers.append("hardcore difficulty")
    else:
        modifiers.append("progression grind")

    return {
        "name": f"{theme} X",
        "core_loop": theme,
        "modifiers": modifiers
    }
