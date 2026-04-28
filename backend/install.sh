#!/usr/bin/env bash

set -e

echo "🚀 Bootstrapping Game Factory AI..."

# ---------- helper ----------
safe_write () {
  mkdir -p "$(dirname "$1")"
  cat > "$1"
}

# ---------- backend ----------

safe_write backend/app/main.py <<'PY'
from fastapi import FastAPI
from app.api import router

app = FastAPI(title="Game Factory AI")
app.include_router(router)
PY

safe_write backend/app/api.py <<'PY'
from fastapi import APIRouter
from app.studio.orchestrator import run_cycle

router = APIRouter()

@router.post("/run")
def run(payload: dict):
    prompt = payload.get("prompt", "")
    return run_cycle(prompt)
PY

safe_write backend/app/studio/orchestrator.py <<'PY'
from app.generator.llm import generate_spec
from app.build.builder import build_unity
from app.qa.swarm import run_swarm
from app.qa.gate import evaluate
from app.publisher.publisher import publish

def run_cycle(prompt: str):
    spec = generate_spec(prompt)
    build = build_unity(spec)
    metrics = run_swarm(build)
    decision = evaluate(metrics)

    if decision["approved"]:
        publish(build)
        return {"status": "published", "score": decision["score"]}

    return {"status": "rejected", "score": decision["score"]}
PY

safe_write backend/app/generator/llm.py <<'PY'
def generate_spec(prompt: str):
    return {
        "name": "AutoGame",
        "genre": "obby",
        "prompt": prompt,
        "mechanics": ["jump", "avoid_lava", "checkpoint"]
    }
PY

safe_write backend/app/build/builder.py <<'PY'
import uuid

def build_unity(spec):
    build_id = str(uuid.uuid4())
    return {
        "build_id": build_id,
        "spec": spec
    }
PY

safe_write backend/app/qa/swarm.py <<'PY'
from app.swarm.engine import run_swarm

def run_swarm_wrapper(build):
    return run_swarm(build, agent_count=300)
PY

safe_write backend/app/qa/gate.py <<'PY'
def evaluate(metrics):
    score = (
        metrics["completion_rate"] * 0.4 +
        metrics["avg_session_time"] / 600 * 0.3 -
        metrics["exploit_rate"] * 0.2
    )
    return {"score": score, "approved": score > 0.5}
PY

safe_write backend/app/publisher/publisher.py <<'PY'
def publish(build):
    print(f"[PUBLISH] {build['build_id']}")
PY

safe_write backend/worker.py <<'PY'
from app.studio.orchestrator import run_cycle

while True:
    prompt = input("Game idea > ")
    print(run_cycle(prompt))
PY

# ---------- swarm ----------

safe_write backend/app/swarm/engine.py <<'PY'
from app.swarm.agents import create_agents

def run_swarm(build, agent_count=300):
    agents = create_agents(agent_count)

    completions = 0
    exploits = 0
    total_time = 0

    for a in agents:
        r = a.simulate(build)
        if r["completed"]:
            completions += 1
        if r["exploited"]:
            exploits += 1
        total_time += r["time"]

    n = len(agents)

    return {
        "completion_rate": completions / n,
        "exploit_rate": exploits / n,
        "avg_session_time": total_time / n
    }
PY

safe_write backend/app/swarm/agents.py <<'PY'
import random
from app.swarm.profile import Agent

def create_agents(n):
    types = ["casual", "speedrunner", "explorer", "exploiter"]
    return [Agent(i, random.choice(types)) for i in range(n)]
PY

safe_write backend/app/swarm/profile.py <<'PY'
import random

class Agent:
    def __init__(self, i, style):
        self.style = style
        self.skill = random.uniform(0.3, 1.0)

    def simulate(self, build):
        base = 0.6
        bias = {"casual": -0.1, "speedrunner": 0.2, "explorer": 0.0, "exploiter": 0.3}[self.style]

        success = self.skill - base + bias
        completed = random.random() < (success + 0.5)

        return {
            "completed": completed,
            "exploited": self.style == "exploiter" and random.random() < 0.2,
            "time": random.uniform(30, 600)
        }
PY

# ---------- infra ----------

safe_write infra/docker-compose.yml <<'YAML'
version: "3.8"
services:
  redis:
    image: redis
    ports:
      - "6379:6379"
YAML

# ---------- dashboard ----------

safe_write dashboard/index.html <<'HTML'
<!DOCTYPE html>
<html>
<body>
<h2>Game Factory AI</h2>
<input id="p" placeholder="game idea">
<button onclick="run()">Run</button>
<pre id="out"></pre>

<script>
async function run(){
  const res = await fetch("http://localhost:8000/run",{
    method:"POST",
    headers:{"Content-Type":"application/json"},
    body:JSON.stringify({prompt:document.getElementById("p").value})
  });
  document.getElementById("out").innerText = await res.text();
}
</script>
</body>
</html>
HTML

# ---------- requirements ----------

safe_write backend/requirements.txt <<'REQ'
fastapi
uvicorn
REQ

echo "✅ Install complete"
