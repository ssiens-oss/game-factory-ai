import random
from collections import deque


class SharedSwarmMemory:
    """
    Central experience buffer shared across all agents.
    """

    def __init__(self, capacity: int = 5000):
        self.buffer = deque(maxlen=capacity)

    def add(self, experience: dict):
        self.buffer.append(experience)

    def sample(self, batch_size: int = 32):
        return random.sample(self.buffer, min(batch_size, len(self.buffer)))

    def size(self):
        return len(self.buffer)
