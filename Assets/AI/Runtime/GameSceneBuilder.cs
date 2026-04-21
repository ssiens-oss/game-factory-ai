using UnityEngine;

public class GameSceneBuilder : MonoBehaviour
{
    public float pressure = 0.5f;
    public float hazardDensity = 0.5f;
    public float chokeBias = 0.5f;

    public GameObject hazardPrefab;
    public GameObject platformPrefab;

    public void UpdateDifficulty(float p, float h)
    {
        pressure = p;
        hazardDensity = h;

        Regenerate();
    }

    public void UpdateChokePoints(float c)
    {
        chokeBias = c;

        Regenerate();
    }

    public void Regenerate()
    {
        foreach (var obj in GameObject.FindGameObjectsWithTag("Generated"))
        {
            Destroy(obj);
        }

        int hazards = Mathf.RoundToInt(hazardDensity * 20);

        for (int i = 0; i < hazards; i++)
        {
            Vector3 pos = new Vector3(Random.Range(-10, 10), 1, Random.Range(-10, 10));
            Instantiate(hazardPrefab, pos, Quaternion.identity);
        }
    }
}
