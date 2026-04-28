#!/bin/bash

PORT=34872

if lsof -i :$PORT >/dev/null 2>&1; then
  PID=$(lsof -ti :$PORT)
  echo "⚠️ Rojo already running (PID $PID)"
  exit 0
else
  echo "🚀 Starting Rojo..."
  cd ~/game-factory-ai/roblox_project
  rojo serve
fi
