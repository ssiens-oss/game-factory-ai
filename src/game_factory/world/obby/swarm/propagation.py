class ExploitPropagation:
    """
    Spreads discovered exploits across agents.
    """

    def propagate(self, agents, exploit_memory):

        for agent in agents:

            for exploit in exploit_memory:

                if exploit not in agent.known_exploits:

                    if agent.skill > 0.6:
                        agent.known_exploits.add(
                            exploit
                        )
