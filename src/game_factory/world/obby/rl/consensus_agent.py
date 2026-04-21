class ConsensusAgent:
    """
    Agent influenced by shared swarm intelligence.
    """

    def __init__(self, agent_id: int, policy, memory):
        self.id = agent_id
        self.policy = policy
        self.memory = memory

        self.last_state = None
        self.last_action = None

        self.finished = False
        self.total_reward = 0

    def act(self, state):
        self.last_state = state
        self.last_action = self.policy.act(state)
        return self.last_action

    def observe(self, reward, next_state):
        self.memory.add({
            "state": self.last_state,
            "action": self.last_action,
            "reward": reward,
            "next_state": next_state
        })

        self.total_reward += reward
