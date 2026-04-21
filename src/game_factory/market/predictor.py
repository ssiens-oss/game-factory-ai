from game_factory.market.feature_extractor import FeatureExtractor
from game_factory.market.player_simulator import PlayerSimulator
from game_factory.market.roi_model import ROIModel


class PredictiveGameEngine:

    def __init__(self):
        self.extractor = FeatureExtractor()
        self.simulator = PlayerSimulator()
        self.roi = ROIModel()

    def evaluate_game(self, game):

        features = self.extractor.extract(game)

        sim = self.simulator.simulate(features)

        prediction = self.roi.predict(sim)

        return {
            "features": features,
            "simulation": sim,
            "prediction": prediction
        }
