class SwarmConsciousAnalyzer:
    """
    Measures emergence of shared intelligence.
    """

    def analyze(self, agents, memory):

        total_reward = sum(a.total_reward for a in agents)
        finishers = sum(1 for a in agents if a.finished)

        return {
            "total_reward": total_reward,
            "finishers": finishers,
            "shared_experience_size": memory.size(),
            "emergence": memory.size() > 1000 and finishers > len(agents) // 2
        }
