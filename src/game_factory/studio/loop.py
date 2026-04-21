import time
from game_factory.studio.orchestrator import run_studio_cycle


def run_continuous_factory(prompt: str, cycles=10):

    results = []

    for i in range(cycles):

        print(f"\n🚀 CYCLE {i+1}")

        result = run_studio_cycle(prompt)

        results.append(result)

        time.sleep(0.5)

    return {
        "total_cycles": cycles,
        "results": results
    }
