using UnityEngine;
using UnityEditor;
using System.IO;

public class PrefabBaker : EditorWindow
{
    [MenuItem("GameFactory/Bake Prefabs")]
    public static void BakePrefabs()
    {
        Debug.Log("Baking AI Prefabs...");

        string root = "Assets/GeneratedPrefabs";
        if (!Directory.Exists(root))
            Directory.CreateDirectory(root);

        // PLATFORM PREFAB
        GameObject platform = GameObject.CreatePrimitive(PrimitiveType.Cube);
        platform.name = "Platform";
        platform.transform.localScale = new Vector3(1, 0.2f, 1);

        SavePrefab(platform, root + "/Platform.prefab");

        // COIN PREFAB
        GameObject coin = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        coin.name = "Coin";
        coin.transform.localScale = new Vector3(0.5f, 0.5f, 0.5f);

        SavePrefab(coin, root + "/Coin.prefab");

        // OBSTACLE PREFAB
        GameObject obstacle = GameObject.CreatePrimitive(PrimitiveType.Cube);
        obstacle.name = "Obstacle";

        SavePrefab(obstacle, root + "/Obstacle.prefab");

        Debug.Log("Prefab Baking Complete.");
    }

    static void SavePrefab(GameObject obj, string path)
    {
        PrefabUtility.SaveAsPrefabAsset(obj, path);
        GameObject.DestroyImmediate(obj);
    }
}
