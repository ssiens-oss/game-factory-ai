from app.swarm.engine import run_swarm

def run_swarm_wrapper(build):
    return run_swarm(build, agent_count=300)
