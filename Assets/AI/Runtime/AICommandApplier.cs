using UnityEngine;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

public class AICommandApplier : MonoBehaviour
{
    public GameSceneBuilder builder;

    public async void Apply(string prompt)
    {
        HttpClient client = new HttpClient();

        var json = "{\"prompt\":\"" + prompt + "\"}";
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        var res = await client.PostAsync("http://localhost:8000/ai/command", content);

        string result = await res.Content.ReadAsStringAsync();

        Debug.Log("AI Result: " + result);

        ApplyToScene(result);
    }

    void ApplyToScene(string json)
    {
        dynamic data = JsonConvert.DeserializeObject(json);

        string action = data.action;

        if (action == "modify_rules")
        {
            float pressure = data.changes.pressure;
            float hazard = data.changes.hazard_density;

            builder.UpdateDifficulty(pressure, hazard);
        }

        if (action == "modify_combat")
        {
            float choke = data.changes.choke_point_bias;
            builder.UpdateChokePoints(choke);
        }
    }
}
