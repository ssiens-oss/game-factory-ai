#!/usr/bin/env python3

VM_POOL = {
    "vm1": {"ip": "192.168.122.101", "role": "casual", "load": 0},
    "vm2": {"ip": "192.168.122.102", "role": "whale", "load": 0},
    "vm3": {"ip": "192.168.122.103", "role": "grinder", "load": 0},
}

def get_available_vm():
    # simple load balancer (replace with RL policy later)
    return min(VM_POOL.items(), key=lambda x: x[1]["load"])

def update_load(vm_id, delta):
    VM_POOL[vm_id]["load"] += delta
