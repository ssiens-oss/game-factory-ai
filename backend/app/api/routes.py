from fastapi import APIRouter, Request
import redis, json, time

router = APIRouter()
r = redis.Redis(host="localhost", port=6379, decode_responses=True)

@router.post("/run")
def run(payload: dict):
    from app.studio.orchestrator import run_cycle
    return run_cycle(payload.get("prompt", "default obby"))

@router.post("/telemetry")
async def telemetry(req: Request):
    data = await req.json()
    data["ts"] = int(time.time())
    data["reward"] = _reward(data)
    r.lpush("telemetry", json.dumps(data))
    return {"ok": True}

@router.get("/metrics")
def metrics():
    raw = r.lrange("telemetry", 0, 200)
    return [json.loads(x) for x in raw]

def _reward(e):
    t = e.get("type", "")
    if t == "session_end":
        return min(2.0, e.get("playtime", 0) / 300)
    if t == "death":
        return -0.05
    return 0.1
