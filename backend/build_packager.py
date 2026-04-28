import json
from pathlib import Path

def package_game(spec, assets):
    build = {
        "gameType": spec["gameType"],
        "difficulty": spec["difficulty"],
        "assets": assets,
        "monetization": spec["monetizationModel"]
    }

    out = Path("./build.json")
    out.write_text(json.dumps(build, indent=2))

    print("📦 Build packaged:", spec["gameType"])
    return out
