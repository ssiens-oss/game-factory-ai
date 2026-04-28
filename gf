#!/bin/bash
ROOT="$HOME/game-factory-ai"
VENV="$ROOT/backend/venv/bin/activate"
cd "$ROOT" || exit 1
export PYTHONPATH="$ROOT/backend"

_activate() { [ -f "$VENV" ] && source "$VENV"; }

doctor() {
  echo "🩺 gf doctor running..."

  # Redis
  if redis-cli ping >/dev/null 2>&1; then
    echo "✅ Redis OK"
  else
    echo "⚠️  Starting Redis..."
    nohup redis-server > logs/redis.log 2>&1 &
    sleep 2
    redis-cli ping >/dev/null && echo "✅ Redis started" || echo "❌ Redis FAILED"
  fi

  # Port 8000
  PID=$(lsof -t -i:8000 2>/dev/null || true)
  [ -n "$PID" ] && { echo "⚠️  Killing :8000 ($PID)"; kill -9 $PID; }

  # Venv
  [ ! -d "$ROOT/backend/venv" ] && python3 -m venv "$ROOT/backend/venv"
  _activate
  pip install --quiet fastapi uvicorn redis requests

  # Rojo port
  RPID=$(lsof -t -i:34872 2>/dev/null || true)
  [ -n "$RPID" ] && { echo "⚠️  Killing :34872 ($RPID)"; kill -9 $RPID; }

  # Start API
  _activate
  nohup python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8000 \
    > logs/api.log 2>&1 & sleep 2
  curl -s http://127.0.0.1:8000/docs >/dev/null \
    && echo "✅ API at http://127.0.0.1:8000" || echo "❌ API failed"

  echo ""; echo "🎯 SYSTEM READY"
}

case "$1" in
  doctor)   doctor ;;
  run)      _activate; python3 launch_factory.py ;;
  api)      _activate; python3 -m uvicorn backend.app.main:app --host 0.0.0.0 --port 8000 ;;
  master)   _activate; cd backend && python3 -m app.studio.master ;;
  worker)   _activate; cd backend && python3 -m app.studio.worker ;;
  rl)       _activate; cd backend && python3 -m app.studio.live_loop ;;
  config)   _activate; python3 config_bus.py ;;
  rojo)     python3 rojo_supervisor.py ;;
  write)
    shift; target="$1"; shift
    mkdir -p "$(dirname "$ROOT/$target")"
    cat > "$ROOT/$target"
    echo "✅ wrote $ROOT/$target"
    ;;
  ls)       find backend/app -name "*.py" | head -40 ;;
  *)
    echo "Usage: gf <command>"
    echo "  doctor  — auto-fix Redis/ports/venv/API"
    echo "  run     — launch entire factory"
    echo "  api     — start FastAPI only"
    echo "  master  — start RL master"
    echo "  worker  — start job worker"
    echo "  rl      — start live RL loop"
    echo "  config  — start Rojo config hot-reload"
    echo "  rojo    — start Rojo supervisor"
    echo "  write <path> — safely write file under project root"
    echo "  ls      — list backend modules"
    ;;
esac
