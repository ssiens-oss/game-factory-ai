from collections import defaultdict


class ObbyGraphBuilder:
    """
    Converts obby level into a traversal graph.
    """

    def build(self, level: dict):
        graph = defaultdict(list)

        platforms = level["platforms"]

        for i in range(len(platforms) - 1):
            a = i
            b = i + 1

            gap = abs(platforms[b]["x"] - platforms[a]["x"])
            difficulty = platforms[b].get("gap_multiplier", 1.0)

            graph[a].append({
                "to": b,
                "cost": gap * difficulty,
                "type": "normal"
            })

            # potential exploit edge (skip)
            if gap < 5:
                graph[a].append({
                    "to": min(i + 2, len(platforms) - 1),
                    "cost": gap * 0.5,
                    "type": "skip_possible"
                })

        return graph
