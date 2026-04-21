import heapq


class HazardAwarePathfinder:
    """
    Finds lowest-risk path through obby.
    """

    def __init__(self, risk_map):
        self.risk = risk_map

    def heuristic(self, a, b):
        return abs(a[0] - b[0])

    def find_path(self, start, goal, nodes):

        pq = []
        heapq.heappush(pq, (0, start, []))

        visited = set()

        while pq:

            cost, node, path = heapq.heappop(pq)

            if node in visited:
                continue

            visited.add(node)

            path = path + [node]

            if node == goal:
                return path

            for n in nodes:

                step_cost = self.risk.get(n, 0.1)

                heapq.heappush(
                    pq,
                    (cost + step_cost, n, path)
                )

        return []
