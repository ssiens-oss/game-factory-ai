class Evolver:

    def improve(self, game, metrics):

        if metrics["avg_success"] < 0.4:
            game["rules"]["pressure"] *= 0.8

        if metrics["exploit_rate"] > 0.5:
            game["rules"]["anti_exploit"] = True

        if metrics["avg_success"] > 0.8:
            game["level_structure"]["zones"] += 1

        return game
