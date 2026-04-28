def compute_ltv(p):
    return (
        p["ltv"] * 2.0 +
        p["sessions"] * 0.5 +
        p["referrals"] * 5.0 -
        p["churn_risk"] * 3.0
    )
