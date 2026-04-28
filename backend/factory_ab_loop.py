import time
import random
from spec_schema import generate_spec
from publisher import deploy_variants
from rl_ab import update_policy

state = {"bias": 1.0}


def loop():
    print("🧠 A/B RL FACTORY ONLINE")

    while True:
        base_spec = generate_spec(
            difficulty=state["bias"],
            seed=random.randint(1, 999999)
        )

        builds = deploy_variants(base_spec)

        print("📦 deployed variants:", builds)

        state_updated = update_policy(state)

        print("📈 updated policy:", state_updated)

        time.sleep(10)


if __name__ == "__main__":
    loop()
