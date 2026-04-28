import time
import subprocess
import json

METRICS_FILE = "/tmp/rl_metrics.json"

def run_iteration():
    print("🚀 Running game iteration")

    subprocess.run(["python3", "../autofill_runner.py"])

    subprocess.run([
        "rojo", "serve", "--port", "34873"
    ])

    # launch studio (adjust path)
    subprocess.run(["RobloxStudioBeta.exe"])

    time.sleep(10)

    with open(METRICS_FILE) as f:
        lines = f.readlines()
        last = json.loads(lines[-1])
        return last

while True:
    m = run_iteration()
    print("📊 Reward:", m["retention"])
    time.sleep(2)
