import redis
import subprocess
import time

r = redis.Redis(host='localhost', port=6379, decode_responses=True)

TARGET_MIN = 1
TARGET_MAX = 5


def get_load():
    return r.llen("jobs")


def vm_count():
    out = subprocess.check_output(["virsh", "list"]).decode()
    return out.count("running")


def scale_up():
    print("🚀 scaling UP")
    subprocess.run(["virsh", "start", "win11"])


def scale_down():
    print("🧯 scaling DOWN (manual safety gate required)")


def loop():
    print("⚙️ autoscaler running")

    while True:
        load = get_load()
        vms = vm_count()

        print("📊 load:", load, "vms:", vms)

        if load > 10 and vms < TARGET_MAX:
            scale_up()

        elif load < 2 and vms > TARGET_MIN:
            scale_down()

        time.sleep(5)


if __name__ == "__main__":
    loop()
