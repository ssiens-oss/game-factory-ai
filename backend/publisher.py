import requests

ROBLOX_API_KEY = "YOUR_OPEN_CLOUD_KEY"
UNIVERSE_ID = "YOUR_UNIVERSE_ID"

def publish(build, thumbnail):
    url = f"https://apis.roblox.com/v1/universes/{UNIVERSE_ID}/places"

    headers = {
        "x-api-key": ROBLOX_API_KEY,
        "Content-Type": "application/json"
    }

    payload = {
        "name": thumbnail["title"],
        "description": f"{build['gameType']} experience optimized by RL system",
        "visibility": "public"
    }

    print("🚀 Publishing game:", payload["name"])

    # NOTE: requires Open Cloud publish permissions enabled
    requests.post(url, headers=headers, json=payload)
