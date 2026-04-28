from app.swarm.engine import run_swarm as _engine

def run_swarm(build):
    return _engine(build, agent_count=300)
