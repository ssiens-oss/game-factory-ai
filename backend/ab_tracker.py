import redis
import json

r = redis.Redis(host='localhost', port=6379, decode_responses=True)


def log_result(build_id, variant, metrics):
    record = {
        "build_id": build_id,
        "variant": variant,
        "completion_rate": metrics.get("completion_rate", 0),
        "avg_session": metrics.get("avg_session", 0),
        "retention": metrics.get("retention", 0),
    }

    r.lpush("ab_metrics", json.dumps(record))


def aggregate():
    data = r.lrange("ab_metrics", 0, 200)

    results = {}

    for item in data:
        m = json.loads(item)
        v = m["variant"]

        if v not in results:
            results[v] = []

        results[v].append(m)

    return results


def best_variant():
    results = aggregate()

    scores = {}

    for v, items in results.items():
        score = sum(i["completion_rate"] + i["retention"] for i in items) / len(items)
        scores[v] = score

    return max(scores, key=scores.get) if scores else None
