from app.studio.orchestrator import run_cycle

while True:
    prompt = input("Game idea > ")
    print(run_cycle(prompt))
