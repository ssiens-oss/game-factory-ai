class CombatEvaluator:

    def evaluate(self, sim_result):

        balance = sim_result["balance_score"]

        fairness = 1.0 - abs(sim_result["red_win_prob"] - sim_result["blue_win_prob"])

        fun_score = (balance * 0.7) + (fairness * 0.3)

        return {
            "balance": balance,
            "fairness": fairness,
            "fun_score": fun_score
        }
