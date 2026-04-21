from game_factory.adversarial.agents import create_adversaries

class AdversarialRunner:

    def run(self, scene: dict):

        agents = create_adversaries()
        logs = []

        for agent in agents:

            path = []

            for step in range(30):

                move = agent.act(scene)

                agent.position["x"] += move["dx"]
                agent.position["y"] += move["dy"]

                path.append(dict(agent.position))

                if agent.position["x"] >= scene["finish"]["x"]:
                    break

            logs.append({
                "agent": agent.name,
                "steps": len(path),
                "finished": agent.position["x"] >= scene["finish"]["x"],
                "path": path
            })

        return logs
