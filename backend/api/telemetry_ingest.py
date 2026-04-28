from fastapi import FastAPI
from pydantic import BaseModel

from rl.global_profile import update
from rl.ltv_model import compute_ltv
from rl.router import route
from rl.viral_rl import reward_action

app = FastAPI()

class Event(BaseModel):
    player: str
    event: str
    value: float = 0
    game: str = "obby"

@app.post("/event")
def ingest(e: Event):

    profile = update(e.player, e.dict())

    ltv = compute_ltv(profile)
    next_game = route(profile)
    viral = reward_action(profile)

    return {
        "ltv": ltv,
        "next_game": next_game,
        "viral": viral
    }
