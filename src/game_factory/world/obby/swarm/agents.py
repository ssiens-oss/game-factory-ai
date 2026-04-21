import random


class SwarmAgent:
    """
    Independent player inside physics emulation swarm.
    """

    def __init__(self, agent_id: int, skill: float = 1.0):
        self.id = agent_id
        self.skill = skill
        self.speed_modifier = random.uniform(0.8, 1.2)

        self.known_exploits = set()
        self.progress = 0
        self.finished = False

    def decide_jump(self, state, exploit_memory):
        """
        Decision influenced by skill + shared exploit knowledge.
        """

        base = self.skill * self.speed_modifier

        if "skip_trick" in exploit_memory:
            base += 0.3

        if random.random() < base:
            return True

        return False
