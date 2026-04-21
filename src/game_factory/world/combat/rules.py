class CombatArenaRules:

    def __init__(self):
        self.team_mode = "ffa"  # or "2v2", "capture_point"

        self.cover_density = 0.5
        self.weapon_density = 0.4

        self.choke_point_bias = 0.6
        self.open_area_ratio = 0.5

        self.spawn_separation = 10.0
