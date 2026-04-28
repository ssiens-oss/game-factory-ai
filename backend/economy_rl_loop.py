#!/usr/bin/env python3

import time

from player_segmentation import get_segments
from economy_brain import balance
from player_rl_policy import generate_player_diff
from diff_engine import apply_diff

def loop():
    print("🧠 ECONOMY RL BRAIN ACTIVE")

    while True:
        segments = get_segments()
        econ = balance(segments)

        print("📊 segments:", {k: len(v) for k, v in segments.items()})
        print("💰 economy:", econ)

        # --- per-player adaptation ---
        for seg, players in segments.items():
            for p in players:
                diff = generate_player_diff(p)

                # inject global economy modifiers
                diff["patch"].update(econ)

                apply_diff(diff)

        time.sleep(3)

if __name__ == "__main__":
    loop()
