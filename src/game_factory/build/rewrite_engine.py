class RewriteEngine:
    """
    Generates improved versions of weak modules.
    """

    def improve(self, path: str, content: str, score: float):
        if score > 80:
            return content

        # lightweight automatic improvement heuristics
        improved = content

        if "pass" in improved:
            improved = improved.replace("pass", "raise NotImplementedError()")

        if len(improved) < 50:
            improved += "\n\n# auto-expanded by self-improving compiler\n"

        return improved
