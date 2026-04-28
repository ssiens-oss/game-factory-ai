#!/usr/bin/env bash

while true; do
  if ! pgrep -f "rojo" > /dev/null; then
    echo "⚠️ Rojo down → restarting"
    rojo serve --port 34873 &
  fi
  sleep 5
done
