from game_factory.playtest.agent import PlaytestAgent

class PlaytestSimulator:

    def run(self, scene: dict, max_steps: int = 50):
        agent = PlaytestAgent()

        log = {
            "steps": 0,
            "coins_collected": 0,
            "finished": False,
            "failed": False
        }

        finish_x = scene.get("finish", {}).get("x", 999)

        for step in range(max_steps):

            if not agent.alive:
                log["failed"] = True
                break

            move = agent.decide_move(scene)
            agent.apply_move(move)

            log["steps"] += 1

            # check finish
            if agent.position["x"] >= finish_x:
                log["finished"] = True
                break

        return {
            "log": log,
            "final_position": agent.position
        }
