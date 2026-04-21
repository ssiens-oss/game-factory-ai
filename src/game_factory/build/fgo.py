from game_factory.build.file_operator import FileGenerationOperator


class AutonomousFileOperator:
    """
    Converts intent → file system actions.
    """

    def __init__(self):
        self.op = FileGenerationOperator()

    def generate(self, spec: dict):
        """
        spec format:
        {
            "path": "...",
            "content": "...",
            "type": "python"
        }
        """

        path = spec["path"]
        content = spec["content"]

        return self.op.create_file(path, content)
