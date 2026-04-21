from prometheus_client import Gauge

FUN = Gauge("game_fun_score", "Fun score")
EXPLOIT = Gauge("game_exploit_score", "Exploit score")
REWARD = Gauge("game_reward", "Reward score")


def push_metrics(fun: int, exploit: int, reward: float):
    FUN.set(fun)
    EXPLOIT.set(exploit)
    REWARD.set(reward)
