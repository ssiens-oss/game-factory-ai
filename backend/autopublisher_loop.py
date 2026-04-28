import random
from game_factory import generate_game_spec
from assets_generator import generate_assets
from build_packager import package_game
from thumbnail_generator import generate_thumbnail
from publisher import publish

def run_once():
    spec = generate_game_spec()

    assets = generate_assets(spec["gameType"])
    build = package_game(spec, assets)
    thumbnail = generate_thumbnail(spec["gameType"])

    publish(build, thumbnail)

def main():
    while True:
        print("🧠 Generating new game...")
        run_once()

        # pacing control (avoid spam publish)
        delay = random.randint(30, 120)
        print("⏳ next publish in", delay, "sec")
        import time
        time.sleep(delay)

if __name__ == "__main__":
    main()
