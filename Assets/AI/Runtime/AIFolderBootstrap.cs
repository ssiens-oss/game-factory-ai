using UnityEngine;
using System.IO;

[InitializeOnLoad]
public static class AIFolderBootstrap
{
    static AIFolderBootstrap()
    {
        Create("Assets/AI");
        Create("Assets/AI/GameTypeRuntime");
        Create("Assets/AI/Runtime");
        Create("Assets/AI/Editor");
        Create("Assets/AI/Prefabs");
        Create("Assets/AI/Samples");
    }

    static void Create(string path)
    {
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
            Debug.Log("Created AI folder: " + path);
        }
    }
}
