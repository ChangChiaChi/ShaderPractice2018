using UnityEngine;

/// <summary>
/// Makes the attached GameObject continuously look at a target transform.
/// </summary>
public class LookAt : MonoBehaviour
{
    [Tooltip("The target transform to look at.")]
    public Transform _go;

    [Tooltip("Optional position offset (currently unused).")]
    public Vector3 _pos;

    private void Start()
    {
        if (_go == null)
        {
            Debug.LogWarning($"[LookAt] Target is not assigned on {gameObject.name}.");
        }
    }

    private void Update()
    {
        if (_go != null)
        {
            transform.LookAt(_go, Vector3.up);
        }
    }

    /// <summary>
    /// Sets the target transform at runtime.
    /// </summary>
    /// <param name="newTarget">The new target to look at.</param>
    public void SetTarget(Transform newTarget)
    {
        _go = newTarget;
    }
}
