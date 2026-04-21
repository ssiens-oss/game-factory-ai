from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()


class Command(BaseModel):
    prompt: str


def interpret(prompt: str):

    prompt = prompt.lower()

    if "more chaotic" in prompt:
        return {
            "action": "modify_rules",
            "changes": {
                "pressure": 0.9,
                "hazard_density": 0.8
            }
        }

    if "easier" in prompt:
        return {
            "action": "modify_rules",
            "changes": {
                "pressure": 0.3,
                "hazard_density": 0.2
            }
        }

    if "tight choke points" in prompt:
        return {
            "action": "modify_combat",
            "changes": {
                "choke_point_bias": 0.9
            }
        }

    return {
        "action": "unknown",
        "message": "Command not recognized yet"
    }


@app.post("/ai/command")
def ai_command(cmd: Command):
    return interpret(cmd.prompt)
