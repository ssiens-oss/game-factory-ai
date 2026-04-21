from game_factory.meta.mechanic_generator import MechanicGenerator

class AutonomousGameDesigner:

    def __init__(self):
        self.mechanic_gen = MechanicGenerator()

    def design_game(self):

        mech = self.mechanic_gen.generate()

        game = {
            "name": mech["name"],
            "rules": mech,
            "level_structure": {
                "zones": 5,
                "progression_curve": "adaptive",
                "failure_states": ["trap", "timeout", "resource_loss"]
            },
            "win_condition": "complete traversal under constraints"
        }

        return game
