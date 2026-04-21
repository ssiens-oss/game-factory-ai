class BaseGameType:

    def generate(self, config):
        raise NotImplementedError

    def simulate(self, level):
        raise NotImplementedError

    def evaluate(self, sim_result):
        raise NotImplementedError

    def export(self, level):
        raise NotImplementedError
