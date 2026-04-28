import time, random

from rl.engine import RLEngine
from roblox.experiment_manager import ExperimentManager

rl = RLEngine()
exp = ExperimentManager()


def base():
    return {
        "seed": random.randint(1, 999999),
        "difficulty": rl.bias,
        "length": 30
    }


def loop():
    print("🎮 STUDIO ONLINE")

    while True:
        spec = base()

        variants = exp.launch(spec)

        print("🧪 variants:", list(variants.keys()))

        rl.update()

        time.sleep(5)


if __name__ == "__main__":
    loop()
