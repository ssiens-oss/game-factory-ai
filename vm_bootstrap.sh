#!/bin/bash

mkdir -p queue results

echo "🤖 worker starting"

python3 worker.py
