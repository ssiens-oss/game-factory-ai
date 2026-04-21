class GameCompiler:

    def compile(self, idea):

        return {
            "name": idea["title"],
            "rules": {
                "pressure": idea["complexity_target"],
                "systems": idea["core_loop"]
            },
            "level_structure": {
                "zones": 4,
                "progression": "adaptive"
            },
            "win_condition": "reach completion under constraints",
            "failure_conditions": ["timeout", "resource loss"]
        }
