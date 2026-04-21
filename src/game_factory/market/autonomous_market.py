from game_factory.market.market_studio import MarketAwareStudio
from game_factory.market.publisher import Publisher


class AutonomousMarketSystem:

    def __init__(self):
        self.studio = MarketAwareStudio()
        self.publisher = Publisher()

    def run(self):

        result = self.studio.run_cycle()

        print("🎮 Studio output:", result)

        return result
