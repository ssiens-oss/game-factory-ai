from game_factory.kernel.self_aware_kernel import SelfAwareEconomicKernel
from game_factory.market.physics import MarketPhysics


class EconomicUniverseKernel:
    """
    Full reflexive economic system.
    """

    def __init__(self):
        self.kernel = SelfAwareEconomicKernel()
        self.market = MarketPhysics()

    def step(self, asset_id: str, demand: float, supply: float, rewards: list):
        price = self.market.update_price(asset_id, demand, supply)

        state = self.kernel.introspect(
            prices=[price],
            rewards=rewards
        )

        adjustments = self.kernel.adjust_economic_laws(state)

        return {
            "price": price,
            "state": state,
            "adjustments": adjustments
        }
