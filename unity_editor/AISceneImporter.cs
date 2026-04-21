using UnityEngine;
using UnityEditor;
using System.Net;
using System.IO;
using System.Collections.Generic;
using Newtonsoft.Json;

public class AISceneImporter : EditorWindow
{
    string apiUrl = "http://127.0.0.1:8000/generate";
    string prompt = "make an obby game with coins and checkpoints";

    [MenuItem("GameFactory/Import AI Scene")]
    public static void ShowWindow()
    {
        GetWindow<AISceneImporter>("AI Scene Importer");
    }

    void OnGUI()
    {
        GUILayout.Label("AI Scene Generator", EditorStyles.boldLabel);

        prompt = EditorGUILayout.TextField("Prompt", prompt);

        if (GUILayout.Button("Generate Scene"))
        {
            GenerateScene();
        }
    }

    void GenerateScene()
    {
        Debug.Log("Calling AI backend...");

        string jsonResponse = PostRequest(apiUrl, prompt);

        Debug.Log(jsonResponse);

        SceneData scene = JsonConvert.DeserializeObject<SceneData>(jsonResponse);

        BuildScene(scene);
    }

    string PostRequest(string url, string prompt)
    {
        var httpWebRequest = (HttpWebRequest)WebRequest.Create(url);
        httpWebRequest.ContentType = "application/json";
        httpWebRequest.Method = "POST";

        using (var streamWriter = new StreamWriter(httpWebRequest.GetRequestStream()))
        {
            string json = "{\"prompt\":\"" + prompt + "\"}";
            streamWriter.Write(json);
        }

        var httpResponse = (HttpWebResponse)httpWebRequest.GetResponse();

        using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
        {
            return streamReader.ReadToEnd();
        }
    }

    void BuildScene(SceneData data)
    {
        GameObject parent = new GameObject("AI_Generated_Scene");

        // PLATFORM
        foreach (var p in data.scene.platforms)
        {
            GameObject obj = GameObject.CreatePrimitive(PrimitiveType.Cube);
            obj.transform.position = new Vector3(p.x, p.y, p.z);
            obj.transform.localScale = new Vector3(1, 0.2f, 1);
            obj.transform.parent = parent.transform;
        }

        // COINS
        foreach (var c in data.scene.coins)
        {
            GameObject coin = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            coin.transform.position = new Vector3(c.x, c.y, c.z);
            coin.name = "Coin";
            coin.transform.parent = parent.transform;
        }

        // OBSTACLES
        foreach (var o in data.scene.obstacles)
        {
            GameObject obs = GameObject.CreatePrimitive(PrimitiveType.Cube);
            obs.transform.position = new Vector3(o.x, o.y, o.z);
            obs.name = "Obstacle";
            obs.transform.parent = parent.transform;
        }

        Debug.Log("AI Scene Build Complete!");
    }

    [System.Serializable]
    public class SceneDataWrapper
    {
        public SceneData scene;
    }

    [System.Serializable]
    public class SceneData
    {
        public List<Pos> platforms;
        public List<Pos> coins;
        public List<Obstacle> obstacles;
    }

    [System.Serializable]
    public class Pos
    {
        public float x;
        public float y;
        public float z;
    }

    [System.Serializable]
    public class Obstacle : Pos
    {
        public string type;
    }
}
