import json
import os

class DesignerMemory:

    def __init__(self, path="ai_memory.json"):
        self.path = path
        self.memory = self.load()

    def load(self):
        if os.path.exists(self.path):
            with open(self.path, "r") as f:
                return json.load(f)
        return {
            "style": {
                "pressure": 0.5,
                "chaos": 0.5,
                "complexity": 0.5
            },
            "history": []
        }

    def update_style(self, changes):
        for k, v in changes.items():
            if k in self.memory["style"]:
                self.memory["style"][k] = (
                    self.memory["style"][k] * 0.7 + v * 0.3
                )

    def log(self, prompt, result):
        self.memory["history"].append({
            "prompt": prompt,
            "result": result
        })

    def save(self):
        with open(self.path, "w") as f:
            json.dump(self.memory, f, indent=2)
EOFcat > src/game_factory/api/collab.py << 'EOF'
from fastapi import WebSocket
from typing import List

clients: List[WebSocket] = []


async def connect(ws: WebSocket):
    await ws.accept()
    clients.append(ws)


async def broadcast(msg: str):
    for c in clients:
        await c.send_text(msg)
