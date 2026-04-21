import random


class CombatSimulator:

    def simulate(self, arena):

        # fake agent model for now (replace with RL later)
        red_score = 0
        blue_score = 0

        # evaluate cover distribution
        cover_value = len(arena["cover"]) * 0.1

        # choke point pressure
        choke_pressure = len(arena["choke_points"]) * 0.2

        # weapon balance
        weapon_value = len(arena["weapons"]) * 0.15

        # simulate outcome bias
        red_score = cover_value + random.uniform(0, choke_pressure)
        blue_score = weapon_value + random.uniform(0, choke_pressure)

        return {
            "red_win_prob": red_score / (red_score + blue_score + 0.01),
            "blue_win_prob": blue_score / (red_score + blue_score + 0.01),
            "balance_score": 1 - abs(red_score - blue_score) / 10
        }
