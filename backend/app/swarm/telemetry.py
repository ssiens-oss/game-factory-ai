def log_swarm_results(results):
    print("=== SWARM REPORT ===")
    print("Completion:", results["completion_rate"])
    print("Failure:", results["failure_rate"])
    print("Exploit Rate:", results["exploit_rate"])
    print("Avg Session:", results["avg_session_time"])
