def score_vulnerability(exploits: list):

    score = 0

    for e in exploits:

        if e["type"] == "skip_exploit":
            score += 50   # very bad

        if e["type"] == "boundary_skip":
            score += 40

        if e["type"] == "economy_abuse":
            score += 30

    return {
        "vulnerability_score": score,
        "is_broken": score > 60
    }
