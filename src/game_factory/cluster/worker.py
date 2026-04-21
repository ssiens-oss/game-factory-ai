from game_factory.world.obby.ecology.engine import MetaConsciousGameEcology


class ObbyWorker:
    """
    Headless simulation worker (no Unity, no rendering).
    """

    def __init__(self, worker_id: str):
        self.id = worker_id
        self.engine = MetaConsciousGameEcology()

    def run_episode(self, level):

        report = self.engine.evolve(level)

        return {
            "worker": self.id,
            "report": report
        }
