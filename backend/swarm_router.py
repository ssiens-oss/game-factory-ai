#!/usr/bin/env python3

import requests
from vm_registry import VM_POOL, get_available_vm

def send_to_vm(vm, diff):
    try:
        url = f"http://{vm['ip']}:8000/apply"
        requests.post(url, json=diff, timeout=1)
    except:
        print("⚠️ VM offline:", vm)

def route_diff(diff):
    vm_id, vm = get_available_vm()

    print(f"📡 routing diff → {vm_id} ({vm['role']})")

    send_to_vm(vm, diff)

    vm["load"] += 1

if __name__ == "__main__":
    route_diff({"patch": {"difficulty": 1.2}})
