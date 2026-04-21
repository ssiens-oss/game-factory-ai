import redis
from rq import Queue

redis_conn = redis.Redis(host="localhost", port=6379)
queue = Queue("game_factory", connection=redis_conn)

def enqueue_job(func, *args, **kwargs):
    return queue.enqueue(func, *args, **kwargs)
