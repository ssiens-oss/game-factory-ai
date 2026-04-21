class EvolutionCore:

    def evolve(self, game, playtest_result):

        score = playtest_result["avg_completion"]

        if score < 0.4:
            game["difficulty"] *= 0.8

        if playtest_result["exploit_rate"] > 0.5:
            game["rules"]["anti_exploit"] = True

        if score > 0.8:
            game["level_structure"]["zones"] += 1

        return game
