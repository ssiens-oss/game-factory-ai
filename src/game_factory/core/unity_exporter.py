import os
import json

def export_to_unity(scene, output_dir="unity_export"):

    os.makedirs(output_dir, exist_ok=True)
    assets_dir = os.path.join(output_dir, "Assets")
    os.makedirs(assets_dir, exist_ok=True)

    # Write scene data as JSON (MVP representation)
    scene_path = os.path.join(assets_dir, "scene.json")

    with open(scene_path, "w") as f:
        json.dump(scene, f, indent=2)

    # Generate simple Unity C# scene loader
    loader_path = os.path.join(assets_dir, "SceneLoader.cs")

    with open(loader_path, "w") as f:
        f.write("""
using UnityEngine;
using System.IO;

public class SceneLoader : MonoBehaviour
{
    void Start()
    {
        string path = Application.dataPath + "/scene.json";
        Debug.Log("Loading scene: " + path);
    }
}
""")

    return output_dir
