import requests

ROBLOX_UPLOAD_ENDPOINT = "https://apis.roblox.com/universes/v1"

def publish(game_path, meta):

    # placeholder for real Open Cloud token flow
    print("📦 Publishing game:", meta["name"])

    # simulate publish response
    return {
        "game_id": meta["name"],
        "status": "published"
    }
