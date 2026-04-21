import os
import ast
from game_factory.build.deps import DependencyIndex


class FileGenerationOperator:
    """
    Dependency-aware autonomous file writer.
    """

    def __init__(self):
        self.deps = DependencyIndex()

    # ----------------------------
    # PUBLIC API
    # ----------------------------

    def create_file(self, path: str, content: str, module_name: str = None):
        self._ensure_dir(path)

        imports = self._extract_imports(content)

        self._auto_stub_missing(imports)

        self._validate_python(content)

        self._write_atomic(path, content)

        if module_name:
            self.deps.register(module_name, imports)

        return {
            "status": "written",
            "module": module_name,
            "imports": list(imports),
            "missing": self.deps.missing_dependencies(module_name) if module_name else []
        }

    # ----------------------------
    # DEPENDENCY LOGIC
    # ----------------------------

    def _extract_imports(self, content: str):
        tree = ast.parse(content)
        imports = set()

        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for n in node.names:
                    imports.add(n.name)

            if isinstance(node, ast.ImportFrom):
                if node.module:
                    imports.add(node.module)

        return imports

    def _auto_stub_missing(self, imports: set):
        """
        Auto-create stub modules for missing dependencies.
        """

        for imp in imports:
            path = "src/" + imp.replace(".", "/") + ".py"

            if not os.path.exists(path):
                os.makedirs(os.path.dirname(path), exist_ok=True)

                with open(path, "w") as f:
                    f.write(f"# AUTO-STUB MODULE: {imp}\n\ndef placeholder():\n    return '{imp} stub'\n")

    # ----------------------------
    # SAFETY LAYERS
    # ----------------------------

    def _ensure_dir(self, path: str):
        os.makedirs(os.path.dirname(path), exist_ok=True)

    def _write_atomic(self, path: str, content: str):
        tmp = path + ".tmp"

        with open(tmp, "w") as f:
            f.write(content)

        os.replace(tmp, path)

    def _validate_python(self, content: str):
        try:
            ast.parse(content)
        except SyntaxError as e:
            raise ValueError(f"Invalid Python: {e}")
