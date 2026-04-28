from app.generator.llm import generate_spec
from app.roblox.generator import generate_lua_game

def run_cycle(prompt: str):
    spec = generate_spec(prompt)

    result = generate_lua_game(spec)

    return {
        "status": "roblox_generated",
        "spec": spec,
        "files": result
    }
