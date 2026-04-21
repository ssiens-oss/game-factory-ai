class GameCatalog:

    def __init__(self):
        self.games = []

    def publish(self, game):
        self.games.append(game)

    def list_games(self):
        return [
            {
                "name": g.get("intent", {}).get("raw"),
                "genre": g.get("intent", {}).get("genre")
            }
            for g in self.games
        ]
