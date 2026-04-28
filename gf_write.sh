#!/bin/bash

target="$1"

if [ -z "$target" ]; then
  echo "Usage: gf_write <path>"
  exit 1
fi

mkdir -p "$(dirname "$target")"

cat > "$target"
echo "✅ wrote $target"
