import time

from game_factory.studio.orchestrator import run_studio_cycle
from game_factory.cluster.queue import dequeue, save_result


def worker_loop(worker_id="worker-1"):

    print(f"⚙️ Worker {worker_id} started")

    while True:

        job = dequeue()

        if not job:
            time.sleep(0.5)
            continue

        print(f"⚙️ {worker_id} processing {job['id']}")

        result = run_studio_cycle(job["prompt"])

        save_result(job["id"], result)

        print(f"✅ {worker_id} completed {job['id']}")
