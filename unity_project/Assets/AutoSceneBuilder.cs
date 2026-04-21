
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
