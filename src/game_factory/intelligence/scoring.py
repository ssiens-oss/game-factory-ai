from game_factory.multiplaytest.arena import CompetitionArena
from game_factory.multiplaytest.scoring import analyze_competition

from game_factory.adversarial.runner import AdversarialRunner
from game_factory.adversarial.exploits import detect_exploits

from game_factory.self_heal.healer import SelfHealingEngine

arena = CompetitionArena()
adversary = AdversarialRunner()
healer = SelfHealingEngine()

def score_game(game: dict):

    # 1. apply learned fixes BEFORE evaluation
    game["scene"] = healer.generate_healed_scene(game["scene"])

    # 2. normal playability test
    results = arena.run(game["scene"])
    metrics = analyze_competition(results)
    base_score = metrics["fun_proxy"]

    # 3. adversarial stress test
    logs = adversary.run(game["scene"])
    exploits = detect_exploits(logs, game["scene"])

    # 4. learning step (THIS is self-healing)
    healer.train_from_scene(game["scene"])

    # 5. penalize brokenness
    exploit_penalty = len(exploits) * 25

    return base_score - exploit_penalty
