import traceback

from game_factory.core.intent_parser import parse_intent
from game_factory.core.game_designer import design_game
from game_factory.core.scene_engine import build_scene
from game_factory.ai.balancer import evaluate_playtest
from game_factory.exporters.unity_exporter import export_to_unity


def process_job(prompt: str):

    try:
        intent = parse_intent(prompt)
        game = design_game(intent)
        scene = build_scene(game)

        evaluation = evaluate_playtest(scene)

        unity = export_to_unity(scene)

        return {
            "intent": intent,
            "game": game,
            "scene": scene,
            "evaluation": evaluation,
            "unity_export": unity
        }

    except Exception:
        print("🔥 WORKER CRASH:")
        traceback.print_exc()

        return {
            "status": "failed"
        }
