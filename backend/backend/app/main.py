from fastapi import FastAPI
from app.api import router

app = FastAPI(title="Game Factory AI")
app.include_router(router)
