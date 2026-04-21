import subprocess
from game_factory.distributed.worker import process


def commit(reward):
    subprocess.run(["git", "add", "."])
    subprocess.run(["git", "commit", "-m", f"evolve reward={reward}"])


def run(seed):
    job = {"id": "seed", "prompt": seed}

    for i in range(10):
        result = process(job)

        print("reward:", result["reward"])

        if result["accepted"]:
            commit(result["reward"])
        else:
            job["prompt"] += " + harder obstacles"

    print("done")
