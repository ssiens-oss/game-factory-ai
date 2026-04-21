from game_factory.market.trend_engine import TrendEngine
from game_factory.market.strategy_engine import StrategyEngine
from game_factory.studio.agent import AutonomousStudioAgent


class MarketAwareStudio:

    def __init__(self):
        self.trends = TrendEngine()
        self.strategy = StrategyEngine()
        self.studio = AutonomousStudioAgent()

    def run_cycle(self):

        ranked = self.trends.get_ranked_trends()

        decision = self.strategy.select_direction(ranked)

        print("📊 MARKET DIRECTION:", decision)

        # inject market bias into studio agent
        self.studio.idea_bias = decision

        catalog = self.studio.run_forever(iterations=10)

        return {
            "decision": decision,
            "games_created": len(catalog)
        }
EOFcat > src/game_factory/market/market_studio.py << 'EOF'
from game_factory.market.trend_engine import TrendEngine
from game_factory.market.strategy_engine import StrategyEngine
from game_factory.studio.agent import AutonomousStudioAgent


class MarketAwareStudio:

    def __init__(self):
        self.trends = TrendEngine()
        self.strategy = StrategyEngine()
        self.studio = AutonomousStudioAgent()

    def run_cycle(self):

        ranked = self.trends.get_ranked_trends()

        decision = self.strategy.select_direction(ranked)

        print("📊 MARKET DIRECTION:", decision)

        # inject market bias into studio agent
        self.studio.idea_bias = decision

        catalog = self.studio.run_forever(iterations=10)

        return {
            "decision": decision,
            "games_created": len(catalog)
        }
