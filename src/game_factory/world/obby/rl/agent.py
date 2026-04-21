from game_factory.world.obby.rl.policy import SwarmPolicy


class RLAgent:
    """
    Learning agent inside obby swarm environment.
    """

    def __init__(self, agent_id: int):
        self.id = agent_id
        self.policy = SwarmPolicy()

        self.state = None
        self.last_state = None
        self.last_action = None

        self.total_reward = 0
        self.finished = False

    def act(self, state):
        self.last_state = self.state
        self.state = state

        action = self.policy.choose_action(state)
        self.last_action = action

        return action

    def learn(self, reward, next_state):
        if self.last_state is None:
            return

        self.policy.update(
            self.last_state,
            self.last_action,
            reward,
            next_state
        )

        self.total_reward += reward
