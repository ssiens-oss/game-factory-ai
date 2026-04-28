def segment(player_state):

    spend = player_state["spend"]
    deaths = player_state["deaths"]

    if spend > 10:
        return "whale"

    if deaths > 20 and spend < 2:
        return "frustrated_grinder"

    if player_state["sessions"] > 20:
        return "loyal_grinder"

    return "casual"
