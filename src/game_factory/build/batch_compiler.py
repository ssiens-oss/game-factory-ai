import os
import ast
from typing import List, Dict


class FileBatchCompiler:
    """
    Compiles a batch of file specs into a full project structure.
    """

    def __init__(self):
        self.results = []

    # ----------------------------
    # ENTRY POINT
    # ----------------------------

    def compile(self, specs: List[Dict]):
        """
        specs format:
        {
            "path": "src/...",
            "content": "...",
            "validate": True
        }
        """

        for spec in specs:
            result = self._process(spec)
            self.results.append(result)

        return self.results

    # ----------------------------
    # CORE PIPELINE
    # ----------------------------

    def _process(self, spec: Dict):
        path = spec["path"]
        content = spec["content"]
        validate = spec.get("validate", True)

        self._ensure_dir(path)

        if validate:
            self._validate_python(content)

        self._write_atomic(path, content)

        return {
            "path": path,
            "status": "written"
        }

    # ----------------------------
    # FILESYSTEM OPS
    # ----------------------------

    def _ensure_dir(self, path: str):
        os.makedirs(os.path.dirname(path), exist_ok=True)

    def _write_atomic(self, path: str, content: str):
        tmp = path + ".tmp"

        with open(tmp, "w") as f:
            f.write(content)

        os.replace(tmp, path)

    # ----------------------------
    # VALIDATION LAYER
    # ----------------------------

    def _validate_python(self, content: str):
        try:
            ast.parse(content)
        except SyntaxError as e:
            raise ValueError(f"Invalid Python: {e}")
