from factory.ideas.generator import generate_idea
from factory.builds.builder import build_game
from publish.roblox.place_upload import upload_place

import time
import os

BASE_PLACE = os.path.expanduser("~/game-factory-ai/roblox_project/dist/base.rbxlx")

def run_pipeline():

    print("🚀 REAL ROBLOX PUBLISH PIPELINE STARTED")

    while True:

        idea = generate_idea(trend_signal=0.6)

        print("🎮 Generated:", idea["name"])

        path = build_game(idea)

        print("🏗 Built:", path)

        # For now: reuse base place (next step = inject scripts dynamically)
        result = upload_place(BASE_PLACE)

        print("🚀 Publish Result:", result)

        time.sleep(30)

if __name__ == "__main__":
    run_pipeline()
