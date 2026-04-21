from game_factory.world.obby.rl.hazard_agent import HazardAwareAgent
from game_factory.world.obby.rl.hazard_reward import HazardRewardModel

from game_factory.cluster.cluster import ObbyTrainingCluster
from game_factory.cluster.aggregator import MetricsAggregator

from game_factory.world.obby.worldgen.hazards import ObbyHazardGenerator
from game_factory.world.obby.swarm.hazard_swarm import HazardSwarm
from game_factory.world.obby.physics.world_mutator import PhysicsWorldMutator

from game_factory.world.obby.ecology.reward_model import AdaptiveRewardModel
from game_factory.world.obby.ecology.world_rules import MutableWorldRules
from game_factory.world.obby.ecology.level_adapter import EcologicalLevelAdapter
from game_factory.world.obby.ecology.observer import EcologyObserver


class MetaConsciousGameEcology:

    def __init__(self):
        self.hazard_agent = HazardAwareAgent()

        self.cluster = ObbyTrainingCluster(num_workers=4)
        self.aggregator = MetricsAggregator()

        self.hazard_gen = ObbyHazardGenerator()
        self.hazard_swarm = HazardSwarm()
        self.hazard_reward = HazardRewardModel()   # 🧠 MULTI-OBJECTIVE SYSTEM

        self.physics = PhysicsWorldMutator()

        self.rewards = AdaptiveRewardModel()
        self.rules = MutableWorldRules()
        self.adapter = EcologicalLevelAdapter()
        self.observer = EcologyObserver()

    def evolve(self, level, cycles=5):

        for c in range(cycles):

            print(f"\n🌍 ecology cycle {c}")

            results = self.cluster.simulate(level)
            metrics = self.aggregator.aggregate(results)

            signals = self.observer.analyze({
                "exploit_rate": metrics["avg_exploit"],
                "completion_rate": metrics["avg_completion"],
                "reward": metrics["avg_reward"]
            })

            # 🧠 swarm produces PHYSICS actions
            swarm_actions = self.hazard_swarm.step({
                "agent_position": {"x": 0, "y": 0},
                "agent_path": [],
                "success_rate": signals["completion_rate"]
            })

            # ⚛️ physics mutation
            level = self.physics.apply(swarm_actions, level)

            # 🧨 procedural hazards
            level = self.hazard_gen.generate(level, signals=signals)

            # 🧠 evaluate outcome
            agent_report = self.hazard_agent.evaluate_level(level)

            # 🧠 compute structured hazard reward (MULTI-OBJECTIVE)
            reward_model = self.hazard_reward.compute({
                "failures": agent_report.get("failures", 0.0),
                "impact_per_change": agent_report.get("impact", 0.0),
                "novelty_score": agent_report.get("novelty", 0.0),
                "targeting_accuracy": agent_report.get("accuracy", 0.0),
                "skill_delta": agent_report.get("skill_delta", 0.0)
            })

            # 🔁 swarm learns from vector reward
            self.hazard_swarm.update(reward_model)

            signals = self.observer.analyze({
                "exploit_rate": signals["exploit_rate"] + agent_report["risk_exposure"],
                "reward": signals["reward"]
            })

            self.rewards.evolve(
                signals["exploit_rate"],
                signals.get("triviality_rate", 0.5)
            )

            self.rules.mutate(
                signals["exploit_rate"],
                signals.get("completion_rate", 0.5)
            )

            level = self.adapter.adapt(level, self.rules)

            print("⚙ rules:", self.rules.snapshot())

        return level
