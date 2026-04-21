from fastapi import FastAPI
from game_factory.api.router import router

app = FastAPI(title="Game Factory AI")

app.include_router(router)
