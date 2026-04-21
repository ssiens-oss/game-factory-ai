import os
import ast


class StructureAnalyzer:
    """
    Evaluates health of generated codebase.
    """

    def analyze_file(self, path: str):
        if not os.path.exists(path):
            return {"status": "missing", "score": 0}

        with open(path, "r") as f:
            content = f.read()

        score = 100

        # syntax health
        try:
            ast.parse(content)
        except SyntaxError:
            return {"status": "broken", "score": 0}

        # heuristics
        if "TODO" in content:
            score -= 10
        if "pass" in content:
            score -= 5
        if len(content) < 20:
            score -= 20

        return {
            "status": "ok",
            "score": max(score, 0)
        }

    def analyze_project(self, files: list):
        total = 0
        for f in files:
            total += self.analyze_file(f).get("score", 0)

        return {
            "project_score": total / max(len(files), 1)
        }
