class Publisher:

    def evaluate_for_publish(self, game, metrics):

        score = metrics.get("avg_success", 0)

        if score > 0.75:
            return "PUBLISH"
        elif score > 0.5:
            return "ITERATE"
        else:
            return "DISCARD"

    def publish(self, game):

        return {
            "status": "published",
            "game": game,
            "store": "simulated_marketplace"
        }
