from fastapi import FastAPI
from pydantic import BaseModel
import time

app = FastAPI()

METRICS = []

class Event(BaseModel):
    player: str
    event: str
    value: float = 0

@app.post("/event")
def ingest(e: Event):
    METRICS.append({
        "t": time.time(),
        "player": e.player,
        "event": e.event,
        "value": e.value
    })
    return {"ok": True}

@app.get("/metrics")
def metrics():
    return METRICS[-100:]
