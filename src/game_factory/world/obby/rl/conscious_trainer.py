from game_factory.world.obby.rl.conscious_env import SwarmConsciousEnvironment


class SwarmConsciousTrainer:
    """
    Trains a shared swarm intelligence system.
    """

    def __init__(self, agent_count: int = 10):
        self.env = SwarmConsciousEnvironment(agent_count)

    def train(self, level: dict, episodes: int = 10):

        for ep in range(episodes):
            states = self.env.reset()

            print(f"\n🧠 consciousness episode {ep}")

            for t in range(200):
                states, rewards = self.env.step(level, states)

            # GLOBAL UPDATE (shared brain update)
            batch = self.env.memory.sample(64)
            self.env.policy.train(batch)

            print("🧬 memory size:", self.env.memory.size())

        return self.env.agents
