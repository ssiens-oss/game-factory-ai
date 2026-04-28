import redis, json

r = redis.Redis(host="localhost", port=6379, decode_responses=True)


def log(event):
    r.lpush("telemetry", json.dumps(event))


def get_all():
    return [json.loads(x) for x in r.lrange("telemetry", 0, 500)]


def reward():
    data = get_all()
    if not data:
        return 0

    return sum(d.get("reward", 0) for d in data) / len(data)
