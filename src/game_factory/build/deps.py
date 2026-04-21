import ast
import os


class DependencyIndex:
    """
    Tracks module import relationships across the system.
    """

    def __init__(self):
        self.graph = {}  # module -> set(imports)

    def scan_file(self, path: str):
        if not os.path.exists(path):
            return set()

        with open(path, "r") as f:
            tree = ast.parse(f.read())

        imports = set()

        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for n in node.names:
                    imports.add(n.name)

            if isinstance(node, ast.ImportFrom):
                if node.module:
                    imports.add(node.module)

        return imports

    def register(self, module: str, imports: set):
        self.graph[module] = imports

    def missing_dependencies(self, module: str):
        deps = self.graph.get(module, set())
        missing = []

        for d in deps:
            try:
                __import__(d)
            except Exception:
                missing.append(d)

        return missing
