from game_factory.multiplaytest.agents import create_population
from game_factory.playtest.sim import PlaytestSimulator

class CompetitionArena:

    def __init__(self):
        self.sim = PlaytestSimulator()

    def run(self, scene: dict):
        agents = create_population()

        results = []

        finish_x = scene.get("finish", {}).get("x", 999)

        for agent in agents:

            log = {
                "agent": agent.name,
                "steps": 0,
                "finished": False,
                "failed": False
            }

            for _ in range(50):

                if not agent.alive:
                    log["failed"] = True
                    break

                move = agent.act(scene)

                agent.position["x"] += move["dx"]
                agent.position["y"] += move["dy"]

                log["steps"] += 1

                if agent.position["x"] >= finish_x:
                    log["finished"] = True
                    break

            results.append({
                "agent": agent.name,
                "log": log
            })

        return results
