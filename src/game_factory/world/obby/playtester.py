from game_factory.world.obby.agents import ObbyBot


class ObbyPlaytester:
    """
    Runs simulated players on generated obbies.
    """

    def run(self, level: dict, bots: int = 10):
        results = []

        for i in range(bots):
            bot = ObbyBot(skill=0.5 + i * 0.05)
            results.append(bot.run_level(level))

        avg_completion = sum(r["completion_rate"] for r in results) / bots

        return {
            "avg_completion": avg_completion,
            "raw": results
        }
