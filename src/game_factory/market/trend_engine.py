import random
import time


class TrendEngine:

    def __init__(self):
        self.mock_trends = [
            "fast movement gameplay",
            "roguelike randomness",
            "physics chaos games",
            "multiplayer survival loops",
            "speedrun optimization",
            "co-op puzzle mechanics"
        ]

    def fetch_trends(self):
        # placeholder for real API scraping later
        return random.sample(self.mock_trends, 3)

    def score_trend(self, trend):
        return random.uniform(0.4, 1.0)

    def get_ranked_trends(self):
        trends = self.fetch_trends()

        return sorted(
            [(t, self.score_trend(t)) for t in trends],
            key=lambda x: x[1],
            reverse=True
        )
