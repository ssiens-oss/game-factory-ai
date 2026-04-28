"""
Single-command launcher:
  python3 launch_factory.py
Starts: API + RL loop + Rojo supervisor + master + worker
"""
import subprocess, time, sys, os
from pathlib import Path

ROOT    = Path(__file__).parent
VENV    = ROOT / "backend/venv/bin/python3"
PYTHON  = str(VENV) if VENV.exists() else sys.executable

os.environ["PYTHONPATH"] = str(ROOT / "backend")

SERVICES = [
    ("API",        [PYTHON, "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"],
                   ROOT / "backend"),
    ("Master",     [PYTHON, "-m", "app.studio.master"],   ROOT / "backend"),
    ("Worker",     [PYTHON, "-m", "app.studio.worker"],   ROOT / "backend"),
    ("LiveLoop",   [PYTHON, "-m", "app.studio.live_loop"],ROOT / "backend"),
    ("ConfigBus",  [PYTHON, str(ROOT / "config_bus.py")], ROOT),
    ("RojoSuperv", [PYTHON, str(ROOT / "rojo_supervisor.py")], ROOT),
]

procs = []

def start_all():
    for name, cmd, cwd in SERVICES:
        p = subprocess.Popen(cmd, cwd=str(cwd))
        procs.append((name, p))
        print(f"▶  {name} started (pid={p.pid})")
        time.sleep(0.5)

def monitor():
    print("\n🎮 Game Factory AI running — Ctrl+C to stop\n")
    try:
        while True:
            for name, p in procs:
                if p.poll() is not None:
                    print(f"⚠️  {name} died (code={p.returncode}) — restart manually if needed")
            time.sleep(5)
    except KeyboardInterrupt:
        print("\n🛑 Shutting down...")
        for _, p in procs:
            p.terminate()

if __name__ == "__main__":
    start_all()
    monitor()
