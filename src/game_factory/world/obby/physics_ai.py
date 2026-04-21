from game_factory.world.obby.physics_graph import PhysicsGraphBuilder
from game_factory.world.obby.physics_pathfinder import PhysicsPathfinder
from game_factory.world.obby.physics_exploit import PhysicsExploitDetector


class PhysicsAwareObbyAI:
    """
    Full physics-constrained obby analysis system.
    """

    def __init__(self):
        self.graph_builder = PhysicsGraphBuilder()
        self.pathfinder = PhysicsPathfinder()
        self.detector = PhysicsExploitDetector()

    def analyze(self, level: dict):
        graph = self.graph_builder.build(level)

        intended = list(range(len(level["platforms"])))

        physics_solution = self.pathfinder.solve(graph)

        report = self.detector.analyze(
            intended,
            physics_solution
        )

        return {
            "physics_path": physics_solution,
            "analysis": report
        }
