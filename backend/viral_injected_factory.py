from game_factory import generate_game_spec
from viral_scraper import fetch_youtube_shorts, extract_viral_signals
from viral_to_game import apply_viral_signals
from viral_scoring import score_trends

def generate_viral_game():
    videos = fetch_youtube_shorts()
    signals = extract_viral_signals(videos)
    trend_scores = score_trends(videos)

    spec = generate_game_spec()

    # 🧠 inject viral bias
    spec = apply_viral_signals(spec, signals)

    # optional global override (market trend dominance)
    if trend_scores["fear"] > 0.4:
        spec["gameType"] = "HORROR"

    if trend_scores["power_fantasy"] > 0.4:
        spec["gameType"] = "SIMULATOR"

    print("🔥 Viral-driven spec:", spec)
    return spec
