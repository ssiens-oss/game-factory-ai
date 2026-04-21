import time
from game_factory.studio.brain import StudioBrain

class StudioOrchestrator:

    def __init__(self):
        self.brain = StudioBrain()

    def run_forever(self, seed: str):

        print("🧠 Autonomous Studio Starting...")

        iteration = 0

        while True:

            print(f"\n🔁 Cycle {iteration}")

            result = self.brain.run_cycle(seed)

            print("📦 Result:", result["status"])

            # slow evolution pacing (simulate production constraints)
            time.sleep(1)

            iteration += 1
