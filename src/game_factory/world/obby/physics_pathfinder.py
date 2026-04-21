import heapq


class PhysicsPathfinder:
    """
    Finds physically valid traversal routes.
    """

    def solve(self, graph, start=0, goal=None):
        if goal is None:
            goal = max(graph.keys())

        pq = [(0, start, [])]
        visited = set()

        while pq:
            cost, node, path = heapq.heappop(pq)

            if node == goal:
                return {
                    "cost": cost,
                    "path": path + [node]
                }

            if node in visited:
                continue

            visited.add(node)

            for edge in graph.get(node, []):
                heapq.heappush(
                    pq,
                    (
                        cost + edge["cost"],
                        edge["to"],
                        path + [node]
                    )
                )

        return None
