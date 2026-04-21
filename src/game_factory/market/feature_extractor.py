class FeatureExtractor:

    def extract(self, game):

        rules = game.get("rules", {})

        return {
            "pressure": rules.get("pressure", 0.5),
            "complexity": len(rules.get("systems", [])),
            "risk_density": rules.get("risk", 0.5),
            "novelty": 0.7,  # placeholder for novelty model
            "multiplayer_bias": 0.3
        }
