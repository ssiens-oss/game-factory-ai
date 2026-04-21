from game_factory.world.obby.emulator.engine import ObbyPhysicsEmulator, PlayerState
from game_factory.world.obby.swarm.agents import SwarmAgent


class SwarmSimulator:
    """
    Runs multi-agent competitive obby simulation.
    """

    def __init__(self, agent_count: int = 10):
        self.agent_count = agent_count
        self.engine = ObbyPhysicsEmulator()

    def run(self, level: dict, steps: int = 200):

        agents = [SwarmAgent(i, skill=0.5 + i * 0.05) for i in range(self.agent_count)]
        states = {a.id: PlayerState() for a in agents}

        exploit_memory = set()
        results = []

        for t in range(steps):

            for agent in agents:

                if agent.finished:
                    continue

                state = states[agent.id]

                jump = agent.decide_jump(state, exploit_memory)

                state = self.engine.step(state, jump)
                states[agent.id] = state

                # finish condition
                if state.x >= level["platforms"][-1]["x"]:
                    agent.finished = True
                    results.append({
                        "agent": agent.id,
                        "time": t
                    })

                # exploit discovery (speed advantage trigger)
                if state.x > 20 and "skip_trick" not in exploit_memory:
                    exploit_memory.add("skip_trick")

        return {
            "results": results,
            "exploit_memory": list(exploit_memory),
            "finish_count": len(results)
        }
