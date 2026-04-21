from fastapi import APIRouter
from pydantic import BaseModel

from game_factory.core.intent_parser import parse_intent
from game_factory.core.game_designer import design_game
from game_factory.core.scene_engine import build_scene
from game_factory.runtime.game_loop import build_game_loop
from game_factory.unity.builder import build_unity_project
from game_factory.unity.prefab_spec import build_prefab_specs

router = APIRouter()

class Prompt(BaseModel):
    prompt: str

@router.post("/generate")
def generate(data: Prompt):

    intent = parse_intent(data.prompt)
    game = design_game(intent)
    scene = build_scene(game)

    loop = build_game_loop(game)
    prefab_specs = build_prefab_specs(scene)

    unity = build_unity_project(scene)

    return {
        "intent": intent,
        "game": game,
        "scene": scene,
        "game_loop": loop,
        "prefab_specs": prefab_specs,
        "unity_project": unity
    }
