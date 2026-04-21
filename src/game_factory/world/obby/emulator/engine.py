import math


class PlayerState:
    def __init__(self):
        self.x = 0.0
        self.y = 1.0
        self.vx = 6.0
        self.vy = 0.0
        self.on_ground = True


class ObbyPhysicsEmulator:
    """
    Deterministic frame-by-frame obby simulation engine.
    """

    def __init__(self):
        self.gravity = -9.8
        self.dt = 0.1  # fixed timestep

    def step(self, state: PlayerState, input_jump: bool):
        # jump
        if input_jump and state.on_ground:
            state.vy = 12.0
            state.on_ground = False

        # gravity
        state.vy += self.gravity * self.dt

        # integrate position
        state.x += state.vx * self.dt
        state.y += state.vy * self.dt

        # ground collision (simple y=0 plane for now)
        if state.y <= 0:
            state.y = 0
            state.vy = 0
            state.on_ground = True

        return state
