import json
from game_factory.build.batch_compiler import FileBatchCompiler


def run(spec_file: str):
    with open(spec_file, "r") as f:
        specs = json.load(f)

    compiler = FileBatchCompiler()
    results = compiler.compile(specs)

    print("🧠 BUILD RESULTS")
    for r in results:
        print(r)


if __name__ == "__main__":
    import sys
    run(sys.argv[1])
