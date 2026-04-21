import random

class PlaytestSwarm:

    def run(self, game):

        agents = ["speedrunner", "exploiter", "casual", "optimizer"]

        results = []

        for a in agents:
            results.append({
                "agent": a,
                "success": random.random(),
                "exploit_found": random.choice([0,1])
            })

        return {
            "avg_success": sum(r["success"] for r in results) / len(results),
            "exploit_rate": sum(r["exploit_found"] for r in results) / len(results)
        }
