import json
import os

from game_factory.world.obby.ecology.engine import MetaConsciousGameEcology


def run_job(job):

    engine = MetaConsciousGameEcology()

    level = job["level"]

    result = engine.evolve(level)

    return {
        "worker": os.getenv("HOSTNAME"),
        "result": result
    }


if __name__ == "__main__":

    # placeholder for queue consumption
    job = json.loads(os.environ.get("JOB", "{}"))

    print(run_job(job))
