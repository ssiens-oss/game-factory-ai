from game_factory.kernel.kernel import GameKernel


def run_kernel(seed: str, iterations: int = 20):
    kernel = GameKernel()
    prompt = seed

    for i in range(iterations):
        print(f"\n🧠 KERNEL STEP {i}")

        result = kernel.step(prompt)

        if result["status"] == "accepted":
            print("✔ accepted reward:", result["reward"])
        else:
            print("✖ rejected → mutating prompt")
            prompt = result["prompt"]

    print("\n🏁 kernel run complete")
