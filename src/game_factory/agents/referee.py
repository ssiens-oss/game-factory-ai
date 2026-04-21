def referee_agent(fun_score: int, exploit_score: int):
    reward = fun_score - exploit_score * 0.5

    return {
        "reward": reward,
        "accept": reward > 60
    }
