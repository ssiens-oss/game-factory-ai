using UnityEditor;
using UnityEngine;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

public class AIEditorAssistantWindow : EditorWindow
{
    string prompt = "";
    string response = "";

    [MenuItem("AI Engine/AI Assistant")]
    public static void Open()
    {
        GetWindow<AIEditorAssistantWindow>("AI Assistant");
    }

    void OnGUI()
    {
        GUILayout.Label("🧠 AI Game Design Assistant", EditorStyles.boldLabel);

        GUILayout.Space(10);

        prompt = EditorGUILayout.TextField("Command:", prompt);

        if (GUILayout.Button("Send"))
        {
            _ = SendPrompt(prompt);
        }

        GUILayout.Space(10);

        GUILayout.Label("Response:");
        GUILayout.TextArea(response, GUILayout.Height(200));
    }

    async Task SendPrompt(string text)
    {
        HttpClient client = new HttpClient();

        var json = "{\"prompt\":\"" + text + "\"}";
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        var res = await client.PostAsync("http://localhost:8000/ai/command", content);

        response = await res.Content.ReadAsStringAsync();

        Debug.Log("AI Response: " + response);
    }
}
