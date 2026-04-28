from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import socket, json, time

WINDOWS_IP = "192.168.122.1"
PORT = 5050
WATCH_PATH = "/home/static/game-factory-ai/backend"


def send(payload):
    try:
        s = socket.socket()
        s.connect((WINDOWS_IP, PORT))
        s.send(json.dumps(payload).encode())
        s.close()
        print("sent:", payload)
    except Exception as e:
        print("send failed:", e)


class Handler(FileSystemEventHandler):
    def on_created(self, event):
        if event.is_directory:
            return

        if "trigger.txt" in event.src_path:
            send({
                "event": "trigger",
                "path": event.src_path
            })


if __name__ == "__main__":
    observer = Observer()
    observer.schedule(Handler(), WATCH_PATH, recursive=True)
    observer.start()

    print("watching:", WATCH_PATH)

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()

    observer.join()
