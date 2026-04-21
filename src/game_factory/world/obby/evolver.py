import copy


class ObbyEvolutionEngine:
    """
    Mutates obby design based on playtest results.
    """

    def evolve(self, level: dict, stats: dict):
        new_level = copy.deepcopy(level)

        score = stats["avg_completion"]

        # TOO HARD → make easier
        if score < 0.4:
            for p in new_level["platforms"]:
                p["gap_multiplier"] = max(0.5, p.get("gap_multiplier", 1.0) - 0.1)

        # TOO EASY → increase difficulty
        elif score > 0.85:
            for p in new_level["platforms"]:
                p["gap_multiplier"] = p.get("gap_multiplier", 1.0) + 0.1

        # ADD VARIATION
        else:
            for p in new_level["platforms"]:
                if random.random() < 0.1:
                    p["moving"] = True

        return new_level
