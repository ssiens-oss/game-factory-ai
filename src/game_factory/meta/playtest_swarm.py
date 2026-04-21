import random

class PlaytestSwarm:

    def simulate(self, game):

        agents = [
            "speedrunner",
            "explorer",
            "exploiter",
            "casual_player"
        ]

        results = []

        for a in agents:
            results.append({
                "agent": a,
                "completion": random.random(),
                "exploit_found": random.choice([True, False]),
                "time": random.uniform(30, 300)
            })

        return {
            "avg_completion": sum(r["completion"] for r in results) / len(results),
            "exploit_rate": sum(r["exploit_found"] for r in results) / len(results),
            "variance": random.random()
        }
