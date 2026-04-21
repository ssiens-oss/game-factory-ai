import random


class SharedSwarmPolicy:
    """
    Collective policy learned from shared memory.
    """

    def __init__(self):
        self.q = {}

    def _key(self, state):
        return round(state.x, 1)

    def act(self, state):
        key = self._key(state)

        if key not in self.q:
            self.q[key] = {"jump": 0.0, "wait": 0.0}

        if random.random() < 0.05:
            return random.choice(["jump", "wait"])

        return max(self.q[key], key=self.q[key].get)

    def train(self, experiences):
        lr = 0.1

        for exp in experiences:
            k = round(exp["state"].x, 1)

            if k not in self.q:
                self.q[k] = {"jump": 0.0, "wait": 0.0}

            self.q[k][exp["action"]] += lr * exp["reward"]
