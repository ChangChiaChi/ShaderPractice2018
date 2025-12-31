using UnityEngine;

namespace ShaderPractice
{
    /// <summary>
    /// Makes the attached GameObject continuously look at a target transform.
    /// </summary>
    public class LookAt : MonoBehaviour
    {
        [Tooltip("The target transform to look at.")]
        [SerializeField] private Transform target;

        [Tooltip("Optional position offset (currently unused).")]
        [SerializeField] private Vector3 positionOffset;

        private void Start()
        {
            if (target == null)
            {
                Debug.LogWarning($"[LookAt] Target is not assigned on {gameObject.name}. Component will be disabled.");
                enabled = false;
            }
        }

        private void Update()
        {
            if (target != null)
            {
                transform.LookAt(target, Vector3.up);
            }
        }

        /// <summary>
        /// Sets the target transform at runtime.
        /// </summary>
        /// <param name="newTarget">The new target to look at.</param>
        public void SetTarget(Transform newTarget)
        {
            target = newTarget;
            enabled = target != null;
        }
    }
}
