import json
import requests
import os

CONFIG_PATH = os.path.expanduser("~/game-factory-ai/backend/secrets/roblox_config.json")

def load_config():
    return json.load(open(CONFIG_PATH))

def publish_experience(name, description="AI generated game"):

    cfg = load_config()

    headers = {
        "x-api-key": cfg["api_key"],
        "Content-Type": "application/json"
    }

    url = f"{cfg['base_url']}/universes/v1/universes/{cfg['universe_id']}/versions"

    payload = {
        "name": name,
        "description": description
    }

    try:
        r = requests.post(url, json=payload, headers=headers)

        print("🔍 STATUS:", r.status_code)
        print("🔍 RESPONSE TEXT:", r.text)

        try:
            return r.json()
        except:
            return {"raw": r.text}

    except Exception as e:
        return {"error": str(e)}
