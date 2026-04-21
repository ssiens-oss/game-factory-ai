import copy


class EcologicalLevelAdapter:
    """
    Rewrites level structure from ecological signals.
    """

    def adapt(self, level, rules):
        new_level = copy.deepcopy(level)

        for p in new_level["platforms"]:

            base_gap = p.get("gap_multiplier", 1.0)

            p["gap_multiplier"] = (
                base_gap * rules.platform_gap_bias
            )

        return new_level
