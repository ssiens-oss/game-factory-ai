from roblox.telemetry import reward

class RLEngine:
    def __init__(self):
        self.bias = 1.0

    def update(self):
        r = reward()

        if r > 1.2:
            self.bias *= 1.05
        else:
            self.bias *= 0.95

        self.bias = max(0.5, min(2.5, self.bias))

        return self.bias
