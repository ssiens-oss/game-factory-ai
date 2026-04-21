using UnityEngine;

public class AutoPlayBot : MonoBehaviour
{
    public float speed = 6f;
    public float jumpPower = 8f;

    private Rigidbody rb;
    private float decisionTimer;

    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    void Update()
    {
        // Auto forward movement
        transform.position += Vector3.right * speed * Time.deltaTime;

        // Simple jump logic (simulate obstacle reaction)
        decisionTimer += Time.deltaTime;

        if (decisionTimer > 1.2f)
        {
            rb.AddForce(Vector3.up * jumpPower, ForceMode.Impulse);
            decisionTimer = 0f;
        }
    }
}
