from game_factory.world.obby.emulator.engine import ObbyPhysicsEmulator, PlayerState
from game_factory.world.obby.emulator.collision import CollisionSystem


class ObbyEmulator:
    """
    Executes full gameplay simulation of obby levels.
    """

    def __init__(self):
        self.engine = ObbyPhysicsEmulator()
        self.collision = CollisionSystem()

    def run(self, level: dict, steps: int = 200):
        state = PlayerState()
        platforms = level["platforms"]

        history = []

        for t in range(steps):

            # simple heuristic input (AI agent placeholder)
            jump = (t % 15 == 0)

            state = self.engine.step(state, jump)

            grounded = self.collision.is_on_platform(state, platforms)

            if grounded:
                state.on_ground = True

            history.append({
                "t": t,
                "x": state.x,
                "y": state.y
            })

            # success condition
            if state.x >= platforms[-1]["x"]:
                return {
                    "success": True,
                    "steps": t,
                    "trace": history
                }

            # fail condition
            if state.y < -10:
                return {
                    "success": False,
                    "steps": t,
                    "trace": history
                }

        return {
            "success": False,
            "steps": steps,
            "trace": history
        }
