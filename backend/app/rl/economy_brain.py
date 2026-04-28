class EconomyBrain:
    def __init__(self):
        self.state = {
            "difficulty_curve":       1.0,
            "monetization_pressure":  1.0,
            "engagement_bias":        1.0,
        }

    def score_player(self, s):
        ltv = (
            (s.get("time", 1)      * 0.04) +
            (s.get("purchases", 0) * 12)   +
            (s.get("progress", 1)  * 1.8)  -
            (s.get("deaths", 0)    * 0.25)
        )
        churn = min(1.0, (
            (0.4 if s.get("time", 60) < 60 else 0) +
            (0.3 if s.get("deaths", 0) > 10 else 0) +
            (0.3 if s.get("progress", 5) < 3 else 0)
        ))
        return ltv, churn

    def decide(self, ltv, churn):
        if ltv > 25 and churn > 0.6:
            return {"mode":"SAVE",       "reviveMult":0.5, "skipMult":0.6, "diffMult":0.85}
        if ltv > 10:
            return {"mode":"OPTIMIZE",   "reviveMult":1.0, "skipMult":1.1, "diffMult":1.05}
        if churn > 0.7:
            return {"mode":"RETENTION",  "reviveMult":0.7, "skipMult":0.7, "diffMult":0.8,
                    "disableMonetization": True}
        return     {"mode":"STANDARD",   "reviveMult":1.0, "skipMult":1.0, "diffMult":1.0}

    def update(self, telemetry_batch):
        if not telemetry_batch:
            return self.state
        avg_deaths = sum(t.get("deaths",0) for t in telemetry_batch) / len(telemetry_batch)
        purchases  = sum(t.get("purchases",0) for t in telemetry_batch)
        if avg_deaths > 5:
            self.state["difficulty_curve"] *= 0.95
        else:
            self.state["difficulty_curve"] *= 1.05
        if purchases < len(telemetry_batch) * 0.1:
            self.state["monetization_pressure"] *= 1.1
        else:
            self.state["monetization_pressure"] *= 0.98
        for k in self.state:
            self.state[k] = max(0.5, min(2.0, self.state[k]))
        return self.state
