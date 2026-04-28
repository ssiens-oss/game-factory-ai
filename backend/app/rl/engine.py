import redis, json

r = redis.Redis(host="localhost", port=6379, decode_responses=True)

class RLEngine:
    def __init__(self):
        self.difficulty = 1.0

    def compute_reward(self, metrics):
        return (
            metrics.get("completion_rate", 0) * 2.0 +
            metrics.get("avg_session_time", 0) / 100.0 -
            metrics.get("exploit_rate", 0) * 0.5
        )

    def update(self, metrics):
        r_val = self.compute_reward(metrics)
        if r_val > 1.2:
            self.difficulty *= 1.05
        elif r_val < 0.6:
            self.difficulty *= 0.95
        self.difficulty = max(0.5, min(3.0, self.difficulty))
        return self.difficulty
