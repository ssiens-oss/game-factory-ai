from game_factory.world.obby.rl.shared_memory import SharedSwarmMemory
from game_factory.world.obby.rl.shared_policy import SharedSwarmPolicy
from game_factory.world.obby.rl.consensus_agent import ConsensusAgent
from game_factory.world.obby.emulator.engine import ObbyPhysicsEmulator, PlayerState


class SwarmConsciousEnvironment:
    """
    Single shared intelligence across many agents.
    """

    def __init__(self, agent_count: int = 10):
        self.memory = SharedSwarmMemory()
        self.policy = SharedSwarmPolicy()
        self.engine = ObbyPhysicsEmulator()

        self.agents = [
            ConsensusAgent(i, self.policy, self.memory)
            for i in range(agent_count)
        ]

    def reset(self):
        return {a.id: PlayerState() for a in self.agents}

    def step(self, level, states):

        rewards = {}

        for agent in self.agents:

            if agent.finished:
                continue

            state = states[agent.id]
            action = agent.act(state)

            jump = (action == "jump")
            next_state = self.engine.step(state, jump)

            reward = next_state.x - state.x

            if next_state.x >= level["platforms"][-1]["x"]:
                reward += 100
                agent.finished = True

            if next_state.y < -5:
                reward -= 20

            agent.observe(reward, next_state)

            states[agent.id] = next_state
            rewards[agent.id] = reward

        return states, rewards
