def apply_viral_signals(spec, signals):
    hooks = signals.get("hooks", [])
    emotions = signals.get("emotional_triggers", [])

    # 🎮 CURATED DESIGN BIASING

    if "time_pressure" in hooks:
        spec["difficulty"] *= 1.2
        spec["length"] = int(spec["length"] * 0.8)

    if "challenge_hook" in hooks:
        spec["difficulty"] *= 1.15

    if "curiosity" in emotions:
        spec["hazard_density"] = min(0.9, spec.get("hazard_density", 0.3) + 0.1)

    if "fear" in emotions:
        spec["gameType"] = "HORROR"

    if "power_fantasy" in emotions:
        spec["gameType"] = "SIMULATOR"

    return spec
