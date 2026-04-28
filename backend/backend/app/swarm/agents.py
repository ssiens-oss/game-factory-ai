import random
from app.swarm.profile import Agent

def create_agents(n):
    types = ["casual", "speedrunner", "explorer", "exploiter"]
    return [Agent(i, random.choice(types)) for i in range(n)]
