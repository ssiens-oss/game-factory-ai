from app.swarm.agents import create_agents

def run_swarm(build, agent_count=300):
    agents = create_agents(agent_count)

    completions = 0
    exploits = 0
    total_time = 0

    for a in agents:
        r = a.simulate(build)
        if r["completed"]:
            completions += 1
        if r["exploited"]:
            exploits += 1
        total_time += r["time"]

    n = len(agents)

    return {
        "completion_rate": completions / n,
        "exploit_rate": exploits / n,
        "avg_session_time": total_time / n
    }
