from flask import Flask, request
import json
import os

app = Flask(__name__)

LOG = "/tmp/rl_metrics.json"

@app.route("/metrics", methods=["POST"])
def metrics():
    data = request.json
    print("📊 METRICS:", data)

    with open(LOG, "a") as f:
        f.write(json.dumps(data) + "\n")

    return {"status": "ok"}

app.run(host="0.0.0.0", port=8000)
