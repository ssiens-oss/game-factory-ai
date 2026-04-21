import time

from game_factory.runtime.job_store import create_job, update_job

FALLBACK_MODE = False

try:
    import redis
    from rq import Queue

    redis_conn = redis.Redis(host="localhost", port=6379)
    redis_conn.ping()

    queue = Queue("game_factory", connection=redis_conn)

    def enqueue_job(func, *args, **kwargs):

        job = create_job(args[0] if args else "unknown")

        def wrapped(*a, **k):
            update_job(job["id"], status="running", progress=10)

            result = func(*a, **k)

            update_job(
                job["id"],
                status="completed",
                progress=100,
                result=result
            )

            return result

        rq_job = queue.enqueue(wrapped, *args, **kwargs)

        job["rq_id"] = rq_job.id
        return job

    print("🟢 Redis mode active")

except Exception as e:
    print(f"🟡 Fallback mode ON ({e})")

    FALLBACK_MODE = True

    def enqueue_job(func, *args, **kwargs):

        job = create_job(args[0] if args else "unknown")

        update_job(job["id"], status="running", progress=20)

        try:
            result = func(*args, **kwargs)

            update_job(
                job["id"],
                status="completed",
                progress=100,
                result=result
            )

            return job

        except Exception as err:

            update_job(
                job["id"],
                status="failed",
                error=str(err)
            )

            return job
