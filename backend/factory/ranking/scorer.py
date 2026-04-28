def score_game(metrics):

    return (
        metrics["ltv"] * 2.0 +
        metrics["retention"] * 3.0 +
        metrics["virality"] * 4.0 -
        metrics["churn"] * 2.0
    )
