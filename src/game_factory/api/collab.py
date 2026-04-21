from fastapi import WebSocket
from typing import List

clients: List[WebSocket] = []


async def connect(ws: WebSocket):
    await ws.accept()
    clients.append(ws)


async def broadcast(msg: str):
    for c in clients:
        await c.send_text(msg)
