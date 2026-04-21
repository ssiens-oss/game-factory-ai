from game_factory.world.obby.graph import ObbyGraphBuilder
from game_factory.world.obby.pathfinder import ObbyPathfinder
from game_factory.world.obby.exploit_detector import ObbyExploitDetector


class DeterministicObbyAI:
    """
    Fully deterministic exploit discovery system.
    """

    def __init__(self):
        self.graph_builder = ObbyGraphBuilder()
        self.pathfinder = ObbyPathfinder()
        self.detector = ObbyExploitDetector()

    def analyze(self, level: dict):
        graph = self.graph_builder.build(level)

        intended = list(range(len(level["platforms"])))

        optimal = self.pathfinder.shortest_path(graph)

        result = self.detector.detect(
            intended_path=intended,
            optimal_path=optimal["path"] if optimal else []
        )

        return {
            "optimal_path": optimal,
            "analysis": result
        }
