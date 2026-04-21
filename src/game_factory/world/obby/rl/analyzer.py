class RLEmergenceAnalyzer:
    """
    Detects emergent behaviors from RL swarm.
    """

    def analyze(self, agents):
        total_reward = sum(a.total_reward for a in agents)
        best_agent = max(agents, key=lambda a: a.total_reward)

        return {
            "total_reward": total_reward,
            "best_agent": best_agent.id,
            "strategy_convergence": len(set(len(a.policy.q) for a in agents)) < 3
        }
