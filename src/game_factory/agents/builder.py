def builder_agent(prompt: str):
    return {
        "type": "build",
        "game": f"generated game from: {prompt}",
        "scene_complexity": "medium"
    }
