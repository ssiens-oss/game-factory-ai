using UnityEngine;
using System.IO;

public class PlaytestManager : MonoBehaviour
{
    public Transform finishLine;
    public Transform player;

    private float startTime;

    void Start()
    {
        startTime = Time.time;
        Debug.Log("Playtest started");
    }

    void Update()
    {
        if (Vector3.Distance(player.position, finishLine.position) < 2f)
        {
            EndTest(true);
        }

        if (player.position.y < -10f)
        {
            EndTest(false);
        }
    }

    void EndTest(bool success)
    {
        float duration = Time.time - startTime;

        var report = new
        {
            success = success,
            time = duration,
            distance = Vector3.Distance(player.position, finishLine.position)
        };

        string json = JsonUtility.ToJson(report, true);

        File.WriteAllText(Application.dataPath + "/playtest_report.json", json);

        Debug.Log("Playtest Complete: " + json);

#if UNITY_EDITOR
        UnityEditor.EditorApplication.isPlaying = false;
#endif
    }
}
