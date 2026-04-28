#!/usr/bin/env python3

import time
from player_state import PLAYER_STATE
from player_rl_policy import generate_player_diff
from diff_engine import apply_diff

def loop():
    print("🧠 PER-PLAYER RL LOOP ACTIVE")

    while True:
        for player_id in list(PLAYER_STATE.keys()):
            diff = generate_player_diff(player_id)

            print(f"🎮 applying diff for {player_id}")
            apply_diff(diff)

        time.sleep(2)

if __name__ == "__main__":
    loop()
