class WorkspaceRegistry:
    """
    Central source of truth for external tool integrations.
    """

    def __init__(self):
        self.workspaces = {}

    def register(self, name: str, root_path: str, adapter):
        self.workspaces[name] = {
            "root": root_path,
            "adapter": adapter
        }

    def get(self, name: str):
        return self.workspaces.get(name)
