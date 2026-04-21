from collections import defaultdict

class FailureMemory:
    """
    Stores recurring exploit + failure patterns.
    """

    def __init__(self):
        self.patterns = defaultdict(int)

    def record(self, exploit_type: str):
        self.patterns[exploit_type] += 1

    def dominant_failures(self):
        return sorted(
            self.patterns.items(),
            key=lambda x: x[1],
            reverse=True
        )
