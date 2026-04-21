import time
from game_factory.distributed.queue import get_job
from game_factory.agents.builder import builder_agent
from game_factory.agents.exploit import exploit_agent
from game_factory.agents.fun import fun_agent
from game_factory.agents.referee import referee_agent


def process(job):
    prompt = job["prompt"]

    game = builder_agent(prompt)
    exploit = exploit_agent(game)
    fun = fun_agent(game)

    decision = referee_agent(fun["fun_score"], exploit["exploit_score"])

    return {
        "job_id": job["id"],
        "game": game,
        "exploit": exploit,
        "fun": fun,
        "reward": decision["reward"],
        "accepted": decision["accept"]
    }


def run_worker():
    print("🧠 Swarm worker online")

    while True:
        job = get_job()

        if not job:
            time.sleep(1)
            continue

        result = process(job)

        print("⚙️ job:", result["job_id"], "reward:", result["reward"])
