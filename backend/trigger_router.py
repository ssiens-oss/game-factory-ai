from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import socket, json, time, uuid

WINDOWS_IP = "192.168.122.77"
PORT = 5050
WATCH_PATH = "/home/static/game-factory-ai/backend"

def send_event(event):
    event["id"] = str(uuid.uuid4())
    payload = json.dumps(event).encode()

    for attempt in range(1, 4):
        try:
            s = socket.socket()
            s.settimeout(3)
            s.connect((WINDOWS_IP, PORT))
            s.send(payload)

            ack = s.recv(4096).decode("utf-8", errors="replace")
            s.close()

            print("sent:", event)
            print("ack:", ack)
            return True

        except Exception as e:
            print(f"retry {attempt}/3 failed:", e)
            time.sleep(1)

    print("failed permanently:", event)
    return False

class Handler(FileSystemEventHandler):
    def on_created(self, event):
        if event.is_directory:
            return

        path = event.src_path

        if path.endswith("trigger.txt"):
            send_event({
                "type": "trigger",
                "path": path,
                "ts": time.time()
            })

        elif path.endswith("build.txt"):
            send_event({
                "type": "build",
                "path": path,
                "ts": time.time()
            })

observer = Observer()
observer.schedule(Handler(), WATCH_PATH, recursive=True)
observer.start()

print("ACK router watching:", WATCH_PATH)

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    observer.stop()

observer.join()
