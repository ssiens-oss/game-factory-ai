from game_factory.cluster.worker import ObbyWorker
import random


class ObbyTrainingCluster:
    """
    Manages distributed obby simulations.
    """

    def __init__(self, num_workers=4):
        self.workers = [
            ObbyWorker(f"worker_{i}")
            for i in range(num_workers)
        ]

    def simulate(self, level, episodes=10):

        results = []

        for _ in range(episodes):

            worker = random.choice(self.workers)

            result = worker.run_episode(level)

            results.append(result)

        return results
