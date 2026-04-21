class GameTypeRegistry:

    _registry = {}

    @classmethod
    def register(cls, name, handler):
        cls._registry[name] = handler

    @classmethod
    def get(cls, name):
        if name not in cls._registry:
            raise ValueError(f"GameType '{name}' not registered")
        return cls._registry[name]

    @classmethod
    def list_types(cls):
        return list(cls._registry.keys())
