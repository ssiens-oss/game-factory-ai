def viral_score(p):
    return (
        p["sessions"] * 0.2 +
        p["referrals"] * 3.0 +
        p["ltv"] * 0.5
    )

def reward_action(p):
    if viral_score(p) > 10:
        return {
            "reward": "exclusive_skin",
            "multiplier": 1.5,
            "prompt_share": True
        }
    return None
