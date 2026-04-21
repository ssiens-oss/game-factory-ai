import os
import json

def build_unity_project(scene, output_dir="unity_project"):

    os.makedirs(output_dir, exist_ok=True)
    assets = os.path.join(output_dir, "Assets")
    os.makedirs(assets, exist_ok=True)

    prefabs_dir = os.path.join(assets, "Prefabs")
    scenes_dir = os.path.join(assets, "Scenes")

    os.makedirs(prefabs_dir, exist_ok=True)
    os.makedirs(scenes_dir, exist_ok=True)

    # ---------------------------
    # 1. Convert scene → prefab specs
    # ---------------------------

    prefabs = []

    for p in scene.get("platforms", []):
        prefabs.append({
            "name": "Platform",
            "position": p,
            "type": "static"
        })

    for c in scene.get("coins", []):
        prefabs.append({
            "name": "Coin",
            "position": c,
            "type": "collectible"
        })

    for o in scene.get("obstacles", []):
        prefabs.append({
            "name": "Obstacle",
            "position": o,
            "type": o.get("type", "block")
        })

    # write prefab spec
    with open(os.path.join(prefabs_dir, "prefabs.json"), "w") as f:
        json.dump(prefabs, f, indent=2)

    # ---------------------------
    # 2. Generate Unity Scene Builder script
    # ---------------------------

    builder_cs = """
using UnityEngine;

public class AutoSceneBuilder : MonoBehaviour
{
    public GameObject platformPrefab;
    public GameObject coinPrefab;
    public GameObject obstaclePrefab;

    void Start()
    {
        BuildScene();
    }

    void BuildScene()
    {
        // NOTE: In real version, this loads JSON
        Debug.Log("Scene Builder Running...");
    }
}
"""

    with open(os.path.join(assets, "AutoSceneBuilder.cs"), "w") as f:
        f.write(builder_cs)

    # ---------------------------
    # 3. Generate simple scene metadata
    # ---------------------------

    scene_meta = {
        "spawn": scene.get("spawn"),
        "finish": scene.get("finish"),
        "prefab_count": len(prefabs)
    }

    with open(os.path.join(scenes_dir, "scene.json"), "w") as f:
        json.dump(scene_meta, f, indent=2)

    return output_dir
