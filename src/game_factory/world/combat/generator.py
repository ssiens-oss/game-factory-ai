import random


class CombatArenaGenerator:

    def generate(self, rules):

        width = 50
        height = 50

        # -------------------------
        # SPAWNS
        # -------------------------
        spawns = [
            {"x": 5, "y": 0, "team": "A"},
            {"x": 45, "y": 0, "team": "B"}
        ]

        # -------------------------
        # COVER OBJECTS
        # -------------------------
        cover = []

        for _ in range(int(rules.cover_density * 30)):
            cover.append({
                "x": random.randint(10, 40),
                "y": 0,
                "type": random.choice(["crate", "wall", "pillar"])
            })

        # -------------------------
        # WEAPONS
        # -------------------------
        weapons = []

        for _ in range(int(rules.weapon_density * 10)):
            weapons.append({
                "x": random.randint(5, 45),
                "y": 0,
                "type": random.choice(["rifle", "shotgun", "sniper"])
            })

        # -------------------------
        # CHOKE POINTS
        # -------------------------
        choke_points = []

        for _ in range(int(rules.choke_point_bias * 5)):
            choke_points.append({
                "x": random.randint(15, 35),
                "y": 0
            })

        return {
            "spawns": spawns,
            "cover": cover,
            "weapons": weapons,
            "choke_points": choke_points,
            "size": {"width": width, "height": height}
        }
EOFcat > src/game_factory/world/combat/simulator.py << 'EOF'
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
