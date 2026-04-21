from game_factory.world.obby.physics import ObbyPhysics


class PhysicsGraphBuilder:
    """
    Builds movement-feasible graph edges using jump physics.
    """

    def __init__(self):
        self.physics = ObbyPhysics()

    def build(self, level: dict):
        nodes = level["platforms"]
        graph = {}

        for i, a in enumerate(nodes):
            graph[i] = []

            for j, b in enumerate(nodes):

                if i == j:
                    continue

                dx = b["x"] - a["x"]
                dy = b["y"] - a["y"]

                if self.physics.can_reach(dx, dy):
                    graph[i].append({
                        "to": j,
                        "cost": abs(dx),
                        "type": "physics_valid_jump"
                    })

                # risky extended jump (possible exploit)
                elif abs(dx) < 15:
                    graph[i].append({
                        "to": j,
                        "cost": abs(dx) * 0.6,
                        "type": "edge_case_jump"
                    })

        return graph
