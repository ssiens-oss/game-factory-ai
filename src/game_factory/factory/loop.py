import random

from game_factory.core.intent_parser import parse_intent
from game_factory.core.game_designer import design_game
from game_factory.core.scene_engine import build_scene
from game_factory.ai.balancer import evaluate_playtest
from game_factory.analytics.aggregator import aggregate_playtests
from game_factory.evolution.memory import update_memory, mutate_from_memory


def simulate_playtest(scene):
    difficulty = len(scene.get("obstacles", [])) * 5
    reward = len(scene.get("coins", [])) * 2

    score = reward - difficulty + random.randint(-10, 10)

    return {
        "success": score > 20,
        "fun_score": score,
        "time": random.uniform(8, 45),
        "distance": random.uniform(10, 100)
    }


def run_factory(prompt, iterations=5, playtests_per_scene=5):

    intent = parse_intent(prompt)
    base_game = design_game(intent)

    candidates = []

    for _ in range(iterations):

        # 🧠 EVOLUTION STEP (KEY ADDITION)
        evolved_game = mutate_from_memory(base_game)

        scene = build_scene(evolved_game)

        playtest_results = []

        for _ in range(playtests_per_scene):
            report = simulate_playtest(scene)
            eval_result = evaluate_playtest(report)

            playtest_results.append({
                "success": report["success"],
                "fun_score": eval_result["fun_score"]
            })

        metrics = aggregate_playtests(playtest_results)

        # 🧠 STORE KNOWLEDGE
        update_memory(scene, metrics)

        candidates.append({
            "scene": scene,
            "metrics": metrics
        })

    ranked = sorted(
        candidates,
        key=lambda x: x["metrics"]["final_score"],
        reverse=True
    )

    return {
        "best_scene": ranked[0]["scene"],
        "best_metrics": ranked[0]["metrics"],
        "ranking": ranked
    }
