import random

GAMES = [
    "obby_core",
    "horror_survival",
    "tycoon_idle",
    "physics_sandbox"
]

def route(player_state):

    ltv = player_state["ltv"]
    skill = player_state["skill"]

    # high value → monetization-heavy games
    if ltv > 20:
        return "tycoon_idle"

    # high skill → harder engagement loops
    if skill > 0.7:
        return "horror_survival"

    # viral entry funnel
    if player_state["sessions"] < 3:
        return "obby_core"

    return random.choice(GAMES)
