#!/bin/bash

PORT=34872

while true; do
  echo "🚀 Checking port $PORT..."

  if lsof -i :$PORT >/dev/null 2>&1; then
    echo "⚠️ Port in use. Killing existing process..."
    lsof -ti :$PORT | xargs kill -9
    sleep 2
  fi

  echo "🚀 Starting Rojo..."
  rojo serve --port $PORT

  echo "⚠️ Rojo exited. Restarting..."
  sleep 2
done
