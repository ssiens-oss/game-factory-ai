#!/usr/bin/env bash
set -e

VM_IP=$(~/game-factory-ai/backend/get_vm_ip.sh)

echo "🚀 RL iteration start"

python3 ~/game-factory-ai/autofill_runner.py

echo "📡 Starting Rojo in correct directory..."
pkill rojo || true
cd ~/game-factory-ai/roblox_project
rojo serve --port 34873 &
sleep 3

echo "🔗 Triggering VM at $VM_IP"
ssh user@$VM_IP "powershell -ExecutionPolicy Bypass -File C:\runner\launch.ps1"

sleep 20

echo "📊 Reading metrics"
tail -n 1 /tmp/rl_metrics.json || echo "⚠️ No metrics yet"

echo "✅ Iteration done"
