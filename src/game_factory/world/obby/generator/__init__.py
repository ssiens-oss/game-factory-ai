from game_factory.world.obby.hazards.spawner import HazardSpawner


class ObbyGenerator:
    """
    Generates platforms + hazards from ecological rules.
    """

    def generate(self, rules, count=20):

        platforms = []
        x = 0

        for i in range(count):

            platforms.append({
                "id": i,
                "x": x,
                "y": 0,
                "gap_multiplier": rules.platform_gap_bias
            })

            x += int(5 * rules.platform_gap_bias)

        spawner = HazardSpawner()

        hazards = spawner.spawn(
            platforms,
            difficulty=rules.platform_gap_bias
        )

        return {
            "platforms": platforms,
            "hazards": hazards
        }
