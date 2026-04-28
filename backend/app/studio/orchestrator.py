from app.generator.llm import generate_spec
from app.build.builder import build_unity
from app.qa.swarm import run_swarm
from app.qa.gate import evaluate
from app.publisher.publisher import publish

def run_cycle(prompt: str):
    spec   = generate_spec(prompt)
    build  = build_unity(spec)
    metrics = run_swarm(build)
    decision = evaluate(metrics)

    if decision["approved"]:
        publish(build)
        return {"status": "published", "score": decision["score"], "spec": spec}

    return {"status": "rejected", "score": decision["score"], "spec": spec}
