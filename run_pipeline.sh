#!/bin/bash
cd ~/game-factory-ai/backend
source venv/bin/activate
PYTHONPATH=. python publish/pipeline.py
