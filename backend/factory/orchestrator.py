import time
from factory.ideas.generator import generate_idea
from factory.builds.builder import build_game
from factory.publish.publisher import publish

def fake_trend():
    return 0.5

def loop():

    print("🧠 AUTONOMOUS GAME FACTORY STARTED")

    while True:

        idea = generate_idea(fake_trend())
        print("🎮 IDEA:", idea)

        path = build_game(idea)
        print("🏗 BUILT:", path)

        result = publish(path, idea)
        print("🚀 PUBLISHED:", result)

        time.sleep(10)

if __name__ == "__main__":
    loop()
