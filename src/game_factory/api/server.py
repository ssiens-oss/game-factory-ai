from fastapi import FastAPI, WebSocket
import asyncio
import json
import time

from game_factory.world.obby.generator import ObbyGenerator
from game_factory.world.obby.worldgen.hazards import ObbyHazardGenerator

app = FastAPI()


# -----------------------------
# LIVE STREAM ENDPOINT
# -----------------------------
@app.websocket("/stream/generate")
async def stream_generate(websocket: WebSocket):
    await websocket.accept()

    data = await websocket.receive_text()
    req = json.loads(data)

    difficulty = req.get("difficulty", 0.5)

    # 🧱 step 1: base generation
    await websocket.send_text(json.dumps({
        "type": "status",
        "message": "generating_base_level"
    }))

    level = ObbyGenerator().generate()

    await asyncio.sleep(0.2)

    await websocket.send_text(json.dumps({
        "type": "level_base",
        "data": level
    }))

    # 🧨 step 2: hazard evolution stages
    for step in range(5):

        await websocket.send_text(json.dumps({
            "type": "status",
            "message": f"applying_hazards_step_{step}"
        }))

        level = ObbyHazardGenerator().generate(
            level,
            signals={
                "exploit_rate": difficulty + step * 0.05,
                "completion_rate": 1 - difficulty,
                "reward": difficulty
            }
        )

        await asyncio.sleep(0.3)

        await websocket.send_text(json.dumps({
            "type": "level_update",
            "step": step,
            "data": level
        }))

    # 🧠 final output
    await websocket.send_text(json.dumps({
        "type": "complete",
        "data": level
    }))

    await websocket.close()
