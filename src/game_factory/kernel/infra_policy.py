"""
Decides how many workers Kubernetes should run
based on system pressure and reward dynamics.
"""

def compute_replica_count(avg_reward, exploit_rate):
    base = 3

    if avg_reward > 70:
        base += 5   # scale successful evolution
    if exploit_rate > 60:
        base += 3   # increase adversarial pressure

    return min(base, 50)
