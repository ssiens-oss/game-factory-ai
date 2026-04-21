class StrategyEngine:

    def select_direction(self, trends):

        top = trends[0][0]

        return {
            "primary_direction": top,
            "hybridization": trends[1][0] if len(trends) > 1 else None,
            "risk_level": "adaptive"
        }
