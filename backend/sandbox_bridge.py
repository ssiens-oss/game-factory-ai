#!/usr/bin/env python3

import requests
from diff_engine import apply_diff

VM_API = "http://192.168.122.77:8000/apply"

def send_diff(diff):
    try:
        requests.post(VM_API, json=diff, timeout=1)
    except:
        print("⚠️ VM unreachable")

def loop():
    print("🔒 sandbox bridge active")

    while True:
        diff = {"patch": {"heartbeat": 1}}
        send_diff(diff)

if __name__ == "__main__":
    loop()
