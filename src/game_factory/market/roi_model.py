class ROIModel:

    def predict(self, sim):

        retention = sim["retention"]
        virality = sim["virality"]

        # simple economic model (expand later to ML regression)
        revenue_score = (
            retention * 0.6 +
            virality * 0.4
        )

        return {
            "roi_score": revenue_score,
            "recommendation": self.classify(revenue_score)
        }

    def classify(self, score):

        if score > 0.75:
            return "BUILD"
        elif score > 0.5:
            return "ITERATE"
        else:
            return "SKIP"
