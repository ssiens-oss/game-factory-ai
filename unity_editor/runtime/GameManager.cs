using UnityEngine;

public class GameManager : MonoBehaviour
{
    public Transform respawnPoint;

    public void PlayerDied(GameObject player)
    {
        player.transform.position = respawnPoint.position;
        Debug.Log("Respawned at checkpoint");
    }

    public void WinGame()
    {
        Debug.Log("YOU WIN!");
    }
}
