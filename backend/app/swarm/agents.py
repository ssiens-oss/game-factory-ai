import random
from app.swarm.profile import Agent

def create_agents(n):
    styles = list(Agent.STYLES.keys())
    return [Agent(i, random.choice(styles)) for i in range(n)]
