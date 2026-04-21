from game_factory.world.obby.emulator.engine import ObbyPhysicsEmulator, PlayerState
from game_factory.world.obby.rl.agent import RLAgent


class RLSwarmEnvironment:
    """
    Reinforcement learning environment for obby swarm agents.
    """

    def __init__(self, agent_count: int = 10):
        self.engine = ObbyPhysicsEmulator()
        self.agents = [RLAgent(i) for i in range(agent_count)]

    def reset(self):
        return {a.id: PlayerState() for a in self.agents}

    def step(self, level: dict, states: dict):

        rewards = {}
        next_states = {}

        for agent in self.agents:

            if agent.finished:
                continue

            state = states[agent.id]

            action = agent.act(state)

            jump = (action == "jump")
            next_state = self.engine.step(state, jump)

            reward = 0.0

            # progress reward
            reward += next_state.x - state.x

            # completion reward
            if next_state.x >= level["platforms"][-1]["x"]:
                reward += 100
                agent.finished = True

            # penalty for falling
            if next_state.y < -5:
                reward -= 20

            agent.learn(reward, next_state)

            rewards[agent.id] = reward
            next_states[agent.id] = next_state

        return next_states, rewards
