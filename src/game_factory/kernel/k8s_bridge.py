import subprocess
import json


def _run(cmd):
    """Safe subprocess wrapper for kernel calls."""
    return subprocess.run(cmd, capture_output=True, text=True)


def get_current_replicas(deployment: str = "game-worker", namespace: str = "default") -> int:
    """
    Queries current replica count from Kubernetes.
    """
    result = _run([
        "kubectl", "get", "deployment", deployment,
        "-n", namespace,
        "-o", "json"
    ])

    if result.returncode != 0:
        return 0

    data = json.loads(result.stdout)
    return data["spec"]["replicas"]


def scale_workers(target_replicas: int, deployment: str = "game-worker", namespace: str = "default"):
    """
    Kernel-controlled scaling syscall with safety bounds.
    """

    # Safety bounds (prevents runaway cluster cost explosion)
    target_replicas = max(1, min(target_replicas, 50))

    current = get_current_replicas(deployment, namespace)

    if current == target_replicas:
        print(f"⚙️ No scaling needed ({current})")
        return

    print(f"🧠 Scaling workers: {current} → {target_replicas}")

    result = _run([
        "kubectl", "scale", "deployment", deployment,
        f"--replicas={target_replicas}",
        "-n", namespace
    ])

    if result.returncode == 0:
        print("✔ scaling successful")
    else:
        print("⚠ scaling failed:", result.stderr)


def autoscale_from_metrics(avg_reward: float, exploit_rate: float):
    """
    Kernel policy hook:
    converts intelligence signals → infrastructure changes.
    """

    base = 3

    if avg_reward > 70:
        base += 5

    if exploit_rate > 60:
        base += 3

    if avg_reward < 30:
        base -= 1

    scale_workers(base)
