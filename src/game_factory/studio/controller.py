import time
import random

from game_factory.factory.loop import run_factory
from game_factory.evolution.memory import update_memory
from game_factory.analytics.aggregator import aggregate_playtests


PUBLISH_THRESHOLD = 70


def studio_cycle(prompt, cycles=10):

    published = []

    for i in range(cycles):

        print(f"🎮 Studio Cycle {i+1}/{cycles}")

        result = run_factory(prompt, iterations=5, playtests_per_scene=5)

        best_scene = result["best_scene"]
        best_metrics = result["best_metrics"]

        # 🧠 FEED LEARNING SYSTEM
        update_memory(best_scene, best_metrics)

        # 🏆 QUALITY GATE
        if best_metrics["final_score"] >= PUBLISH_THRESHOLD:
            published.append({
                "scene": best_scene,
                "metrics": best_metrics,
                "status": "published"
            })
            print("📦 Published game!")
        else:
            print("❌ Rejected (low quality)")

        time.sleep(0.5)  # simulate pipeline pacing

    return {
        "published_count": len(published),
        "published_games": published
    }
