#!/bin/bash

set -e

dirs=(
  src/game_factory/kernel
  src/game_factory/physics
  src/game_factory/world
  src/game_factory/civilization
  src/game_factory/economy
  src/game_factory/meta
  src/game_factory/market
  src/game_factory/multiverse
)

for d in "${dirs[@]}"; do
  mkdir -p "$d"
done

echo "✅ Game Factory structure initialized"
