import json, time, requests
from pathlib import Path

# 🧠 versioned economy configs
CONFIG_PATH = Path("./economy_config.json")

ROBLOX_API_KEY = "YOUR_OPEN_CLOUD_KEY"
UNIVERSE_ID = "YOUR_UNIVERSE_ID"

def load_config():
    if CONFIG_PATH.exists():
        return json.loads(CONFIG_PATH.read_text())
    return {
        "reviveMult": 1.0,
        "skipMult": 1.0,
        "difficultyMult": 1.0,
        "version": 1
    }

def push_to_roblox(config):
    # 🧠 Open Cloud Datastore API (simplified example)
    url = f"https://apis.roblox.com/datastores/v1/universes/{UNIVERSE_ID}/standard-datastores/datastore/entries/LiveEconomy"

    headers = {
        "x-api-key": ROBLOX_API_KEY,
        "Content-Type": "application/json"
    }

    payload = {
        "data": config
    }

    print("🚀 pushing config:", config)

    # NOTE: requires Open Cloud enabled datastore permissions
    requests.post(url, headers=headers, json=payload)

def evaluate_and_update():
    config = load_config()

    # 🧠 fake RL improvement loop (replace with real telemetry ingestion later)
    config["reviveMult"] *= 1.02
    config["skipMult"] *= 0.99
    config["difficultyMult"] *= 1.01
    config["version"] += 1

    # clamp
    config["reviveMult"] = max(0.5, min(2.0, config["reviveMult"]))
    config["skipMult"] = max(0.5, min(2.5, config["skipMult"]))
    config["difficultyMult"] = max(0.7, min(2.0, config["difficultyMult"]))

    CONFIG_PATH.write_text(json.dumps(config, indent=2))
    push_to_roblox(config)

if __name__ == "__main__":
    while True:
        evaluate_and_update()
        time.sleep(30)
