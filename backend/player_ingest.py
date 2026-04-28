#!/usr/bin/env python3

from fastapi import FastAPI
from player_state import update_player

app = FastAPI()

@app.post("/event")
def ingest(event: dict):
    player_id = event.get("player", "unknown")

    update_player(player_id, event)

    return {"ok": True}
