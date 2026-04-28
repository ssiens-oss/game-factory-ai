import requests
import re

# NOTE: Replace with official API keys (TikTok/YouTube Data API)
YOUTUBE_API_KEY = "YOUR_YOUTUBE_KEY"

def fetch_youtube_shorts(query="gaming shorts"):
    url = (
        "https://www.googleapis.com/youtube/v3/search"
        f"?part=snippet&maxResults=25&q={query}&key={YOUTUBE_API_KEY}"
    )

    data = requests.get(url).json()

    videos = []
    for item in data.get("items", []):
        snippet = item.get("snippet", {})
        title = snippet.get("title", "")

        videos.append({
            "title": title,
            "channel": snippet.get("channelTitle"),
            "published": snippet.get("publishedAt")
        })

    return videos


def extract_viral_signals(videos):
    signals = {
        "hooks": [],
        "emotional_triggers": [],
        "patterns": []
    }

    for v in videos:
        t = v["title"].lower()

        # 🎯 hook patterns
        if "don't" in t or "you won't" in t:
            signals["hooks"].append("challenge_hook")

        if "i tried" in t:
            signals["hooks"].append("experimentation_hook")

        if "100 days" in t or "1 hour" in t:
            signals["hooks"].append("time_pressure")

        # emotional triggers
        if "scary" in t or "horror" in t:
            signals["emotional_triggers"].append("fear")

        if "secret" in t or "hidden" in t:
            signals["emotional_triggers"].append("curiosity")

        if "overpowered" in t or "broken" in t:
            signals["emotional_triggers"].append("power_fantasy")

    return signals
