def optimizer_agent(prompt: str, exploit_report: dict):
    if exploit_report["exploit_score"] > 50:
        return prompt + " + anti-cheat + collision fixes"
    return prompt + " + dynamic obstacles"
