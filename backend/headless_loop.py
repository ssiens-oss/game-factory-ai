import json, time, random
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
CTRL = BASE / "roblox_project/control/control.json"
TELE = BASE / "roblox_project/control/telemetry.json"

def write_control(run_id, spec):
    CTRL.parent.mkdir(parents=True, exist_ok=True)
    CTRL.write_text(json.dumps({
        "run_id": run_id,
        "status": "pending",
        "spec": spec
    }))

def read_control():
    if not CTRL.exists(): return None
    return json.loads(CTRL.read_text())

def wait_done(run_id, timeout=300):
    t0 = time.time()
    while time.time() - t0 < timeout:
        ctrl = read_control()
        if ctrl and ctrl.get("run_id") == run_id and ctrl.get("status") == "done":
            return True
        time.sleep(1)
    return False

def read_telemetry(run_id):
    if not TELE.exists(): return None
    data = json.loads(TELE.read_text())
    if data.get("run_id") == run_id:
        return data
    return None

def update_model(stats, difficulty):
    if not stats: return difficulty
    deaths = stats.get("deaths", 0)

    if deaths > 150:
        return max(0.7, difficulty * 0.9)
    else:
        return min(1.6, difficulty * 1.1)

def main():
    difficulty = 1.0

    while True:
        run_id = random.randint(1000, 9999)

        spec = {
            "seed": random.randint(1, 999999),
            "length": 30,
            "difficulty": difficulty,
            "agents": 60,
            "duration": 45
        }

        print("🧠 Dispatch:", run_id, spec)
        write_control(run_id, spec)

        ok = wait_done(run_id)
        if not ok:
            print("⏰ Timeout, retrying...")
            continue

        data = read_telemetry(run_id)
        print("📊 Telemetry:", data)

        stats = data["stats"] if data else {}
        difficulty = update_model(stats, difficulty)

        time.sleep(1)

if __name__ == "__main__":
    main()
