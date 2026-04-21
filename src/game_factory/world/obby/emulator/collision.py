class CollisionSystem:
    """
    Minimal platform collision detection.
    """

    def is_on_platform(self, state, platforms):
        for p in platforms:
            px, py = p["x"], p["y"]

            if abs(state.x - px) < 1.5 and abs(state.y - py) < 0.5:
                return True

        return False
