from game_factory.build.batch_compiler import FileBatchCompiler
from game_factory.build.structure_analyzer import StructureAnalyzer
from game_factory.build.rewrite_engine import RewriteEngine


class SelfImprovingCompiler:
    """
    Closed-loop autonomous codebase evolution engine.
    """

    def __init__(self):
        self.compiler = FileBatchCompiler()
        self.analyzer = StructureAnalyzer()
        self.rewriter = RewriteEngine()

    # ----------------------------
    # MAIN LOOP
    # ----------------------------

    def run(self, specs, iterations: int = 2):
        last_output = None

        for i in range(iterations):
            print(f"\n🧠 ITERATION {i}")

            # 1. compile
            results = self.compiler.compile(specs)

            # 2. analyze
            files = [r["path"] for r in results]
            report = self.analyzer.analyze_project(files)

            print("📊 score:", report["project_score"])

            # 3. rewrite if needed
            if report["project_score"] < 80:
                specs = self._improve_specs(specs)
            else:
                print("✅ system stable")
                break

            last_output = results

        return last_output

    # ----------------------------
    # EVOLUTION STEP
    # ----------------------------

    def _improve_specs(self, specs):
        improved = []

        for s in specs:
            score = self.analyzer.analyze_file(s["path"])["score"]
            new_content = self.rewriter.improve(
                s["path"],
                s["content"],
                score
            )

            improved.append({
                "path": s["path"],
                "content": new_content
            })

        return improved
