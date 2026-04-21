import multiprocessing
from game_factory.cluster.worker import worker_loop


def start_cluster(worker_count=4):

    processes = []

    for i in range(worker_count):
        p = multiprocessing.Process(
            target=worker_loop,
            args=(f"worker-{i}",)
        )
        p.start()
        processes.append(p)

    for p in processes:
        p.join()
