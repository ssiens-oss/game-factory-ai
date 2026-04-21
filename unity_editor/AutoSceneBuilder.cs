using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

public class AutoSceneBuilder : EditorWindow
{
    [MenuItem("GameFactory/Build Scene")]
    public static void BuildScene()
    {
        Debug.Log("Game Factory: Building Scene...");

        GameObject parent = new GameObject("GeneratedScene");

        // PLATFORM ROW
        for (int i = 0; i < 25; i++)
        {
            GameObject platform = GameObject.CreatePrimitive(PrimitiveType.Cube);
            platform.transform.position = new Vector3(i * 2, 0, 0);
            platform.transform.localScale = new Vector3(1, 0.2f, 1);
            platform.transform.parent = parent.transform;
        }

        // COINS
        for (int i = 0; i < 25; i += 2)
        {
            GameObject coin = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            coin.transform.position = new Vector3(i * 2, 1, 0);
            coin.name = "Coin";
            coin.transform.parent = parent.transform;
        }

        // OBSTACLES
        for (int i = 10; i < 25; i += 5)
        {
            GameObject obstacle = GameObject.CreatePrimitive(PrimitiveType.Cube);
            obstacle.transform.position = new Vector3(i * 2, 1, 0);
            obstacle.name = "Obstacle";
            obstacle.transform.parent = parent.transform;
        }

        Debug.Log("Scene generation complete.");
    }
}
