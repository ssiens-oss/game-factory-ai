import os
import json
import requests

CONFIG = os.path.expanduser("~/game-factory-ai/backend/secrets/roblox_config.json")

def load():
    return json.load(open(CONFIG))

def upload_place(file_path):

    cfg = load()

    place_id = cfg.get("place_id")
    api_key = cfg.get("api_key")

    if not place_id:
        return {"error": "Missing place_id in config"}

    url = f"https://apis.roblox.com/universes/v1/places/{place_id}/versions?versionType=Published"

    headers = {
        "x-api-key": api_key,
        "Content-Type": "application/octet-stream"
    }

    with open(file_path, "rb") as f:
        data = f.read()

    r = requests.post(url, headers=headers, data=data)

    print("🔍 STATUS:", r.status_code)
    print("🔍 RESPONSE:", r.text)

    try:
        return r.json()
    except:
        return {"raw": r.text}
