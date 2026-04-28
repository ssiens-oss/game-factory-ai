"""
Self-healing Rojo supervisor:
- kills stale port holders
- exponential backoff restarts
- structured logging
- max restart limit
"""
import subprocess, socket, os, time, sys
from datetime import datetime
from pathlib import Path

PORT        = 34872
MAX_RESTART = 50
LOG_FILE    = Path(__file__).parent / "logs/rojo_supervisor.log"
PROJECT_DIR = Path(__file__).parent / "roblox_project"

def log(msg):
    line = f"[{datetime.now().isoformat()}] {msg}"
    print(line)
    LOG_FILE.parent.mkdir(exist_ok=True)
    with open(LOG_FILE, "a") as f:
        f.write(line + "\n")

def port_busy(port):
    try:
        s = socket.create_connection(("127.0.0.1", port), timeout=1)
        s.close(); return True
    except: return False

def kill_port(port):
    os.system(f"lsof -ti :{port} | xargs kill -9 2>/dev/null || true")

def classify(output):
    t = output.lower()
    if "address already in use" in t: return "port_conflict"
    if "permission"             in t: return "permission_denied"
    if "not found"              in t: return "rojo_missing"
    return "unknown"

def run():
    backoff  = 2
    restarts = 0
    while restarts < MAX_RESTART:
        if port_busy(PORT):
            log(f"⚠️  Port {PORT} busy — killing stale process")
            kill_port(PORT)
            time.sleep(1)

        log("🚀 Starting Rojo")
        proc = subprocess.Popen(
            ["rojo", "serve", "--port", str(PORT)],
            cwd=str(PROJECT_DIR),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True
        )

        buf = []
        healthy = False
        for line in proc.stdout:
            line = line.rstrip()
            buf.append(line)
            print(line)
            if "listening" in line.lower() or "34872" in line:
                log("✅ Rojo healthy on :" + str(PORT))
                healthy = True
                backoff = 2   # reset backoff on success

        proc.wait()
        reason = classify("\n".join(buf))
        restarts += 1
        log(f"⚠️  Rojo exited (reason={reason}, attempt={restarts})")
        sleep = min(60, backoff * (2 ** min(restarts, 5)))
        log(f"🔁 Restart in {sleep}s")
        time.sleep(sleep)

    log("❌ Max restarts reached — exiting supervisor")

if __name__ == "__main__":
    run()
