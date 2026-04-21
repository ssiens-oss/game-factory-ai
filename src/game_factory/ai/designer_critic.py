class DesignerCritic:

    def review(self, level):

        issues = []

        if level.get("hazards", []):
            if len(level["hazards"]) > 20:
                issues.append("Too dense hazard placement")

        if level.get("difficulty", 0.5) > 0.8:
            issues.append("Difficulty spike too aggressive")

        if level.get("choke_points", 0) > 5:
            issues.append("Overuse of choke points reduces flow")

        return {
            "score": max(0.0, 1.0 - len(issues) * 0.2),
            "issues": issues,
            "suggestions": [
                "smooth difficulty curve",
                "add recovery platforms",
                "reduce hazard clustering"
            ]
        }
