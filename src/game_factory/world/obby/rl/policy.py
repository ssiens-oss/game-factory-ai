import random


class SwarmPolicy:
    """
    Lightweight Q-learning style policy for obby agents.
    """

    def __init__(self):
        self.q = {}  # state-action values

    def _state_key(self, state):
        return round(state.x, 1)

    def choose_action(self, state):
        key = self._state_key(state)

        if key not in self.q:
            self.q[key] = {"jump": 0.0, "wait": 0.0}

        if random.random() < 0.1:
            return random.choice(["jump", "wait"])

        return max(self.q[key], key=self.q[key].get)

    def update(self, state, action, reward, next_state):
        key = self._state_key(state)

        if key not in self.q:
            self.q[key] = {"jump": 0.0, "wait": 0.0}

        lr = 0.1
        self.q[key][action] += lr * reward
