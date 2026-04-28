#!/usr/bin/env python3

import time, random
from player_segmentation import get_segments
from economy_brain import balance
from player_rl_policy import generate_player_diff
from swarm_router import route_diff

def loop():
    print("🧠 RL SWARM CONTROLLER ACTIVE")

    while True:
        segments = get_segments()
        econ = balance(segments)

        for seg, players in segments.items():

            for p in players:
                diff = generate_player_diff(p)

                # inject global economy state
                diff["patch"].update(econ)

                # 🧠 route to best VM
                route_diff(diff)

        time.sleep(2)

if __name__ == "__main__":
    loop()
