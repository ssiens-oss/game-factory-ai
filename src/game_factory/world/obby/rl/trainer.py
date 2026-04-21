from game_factory.world.obby.rl.environment import RLSwarmEnvironment


class ObbyRLSwarmTrainer:
    """
    Trains swarm agents on obby levels.
    """

    def __init__(self, agent_count: int = 10):
        self.env = RLSwarmEnvironment(agent_count=agent_count)

    def train(self, level: dict, episodes: int = 10):

        for ep in range(episodes):
            states = self.env.reset()

            print(f"\n🧠 episode {ep}")

            for t in range(200):
                states, rewards = self.env.step(level, states)

            avg_reward = sum(rewards.values()) / len(rewards)
            print("📊 avg reward:", avg_reward)

        return self.env.agents
