from rl.player_state import load, update
from rl.segmentation import segment
from rl.pricing_bandit import select_arm, update as bandit_update

def compute_reward(state):
    return state["spend"] * 2 - state["churn_risk"]

def step(player, event):

    state = update(player, event)
    seg = segment(state)

    price = select_arm()

    reward = compute_reward(state)
    bandit_update(price, reward)

    # segmentation policy tuning
    if seg == "whale":
        price *= 1.2
    elif seg == "frustrated_grinder":
        price *= 0.7

    return {
        "segment": seg,
        "price": round(price, 2),
        "state": state
    }
