using UnityEngine;
using UnityEditor;

public class PlaytestLauncher : EditorWindow
{
    [MenuItem("GameFactory/Run Auto Playtest")]
    public static void RunTest()
    {
        Debug.Log("Starting Playtest Mode...");
        EditorApplication.isPlaying = true;
    }
}
