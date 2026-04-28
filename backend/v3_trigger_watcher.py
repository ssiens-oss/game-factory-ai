import json, socket, time, pathlib

HOST = "192.168.122.77"
PORT = 5050
WATCH = pathlib.Path.home() / "game-factory-ai" / "backend" / "trigger.txt"

print("GF V3 watcher")
print("watching:", WATCH)

last = None

while True:
    try:
        if WATCH.exists():
            m = WATCH.stat().st_mtime
            if last is None:
                last = m
            elif m != last:
                last = m
                payload = {
                    "type": "trigger",
                    "path": str(WATCH),
                    "action": "install_plugin",
                    "plugin_file": str(pathlib.Path.home() / "game-factory-ai" / "backend" / "GameFactoryAI_V3_Ultimate.lua"),
                    "ts": time.time(),
                }
                s = socket.socket()
                s.settimeout(5)
                s.connect((HOST, PORT))
                s.send(json.dumps(payload).encode("utf-8"))
                print("sent:", s.recv(2048))
                s.close()
        time.sleep(0.5)
    except Exception as e:
        print("send failed:", e)
        time.sleep(2)
