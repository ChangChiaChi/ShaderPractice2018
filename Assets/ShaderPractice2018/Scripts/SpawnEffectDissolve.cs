using UnityEngine;

namespace ShaderPractice
{
    /// <summary>
    /// Controls a dissolve spawn effect that cycles through a dissolve animation
    /// using particle systems and material property changes.
    /// </summary>
    public class SpawnEffectDissolve : MonoBehaviour
    {
        private static readonly int DissolveThresholdProperty = Shader.PropertyToID("_DissolveThreshold");

        [Header("Effect Timing")]
        [Tooltip("Duration of the spawn/dissolve effect in seconds.")]
        [SerializeField] private float effectDuration = 2f;

        [Tooltip("Pause duration between effect cycles in seconds.")]
        [SerializeField] private float pauseDuration = 1f;

        [Header("Animation")]
        [Tooltip("Animation curve controlling the dissolve fade-in.")]
        [SerializeField] private AnimationCurve fadeInCurve = AnimationCurve.Linear(0, 0, 1, 1);

        private ParticleSystem particleSystem;
        private Renderer objectRenderer;
        private MaterialPropertyBlock propertyBlock;
        private float timer;

        private void Start()
        {
            if (!Initialize())
            {
                enabled = false;
            }
        }

        /// <summary>
        /// Initializes required components and validates references.
        /// </summary>
        private bool Initialize()
        {
            objectRenderer = GetComponent<Renderer>();
            if (objectRenderer == null)
            {
                Debug.LogError($"[SpawnEffectDissolve] No Renderer found on {gameObject.name}.");
                return false;
            }

            particleSystem = GetComponentInChildren<ParticleSystem>();
            if (particleSystem == null)
            {
                Debug.LogError($"[SpawnEffectDissolve] No ParticleSystem found in children of {gameObject.name}.");
                return false;
            }

            // Initialize property block for efficient material property updates
            propertyBlock = new MaterialPropertyBlock();

            // Configure particle system duration
            var main = particleSystem.main;
            main.duration = effectDuration;

            // Start the effect
            particleSystem.Play();

            return true;
        }

        private void Update()
        {
            UpdateTimer();
            UpdateDissolveEffect();
        }

        /// <summary>
        /// Updates the timer and restarts the effect cycle when complete.
        /// </summary>
        private void UpdateTimer()
        {
            float cycleDuration = effectDuration + pauseDuration;

            if (timer < cycleDuration)
            {
                timer += Time.deltaTime;
            }
            else
            {
                particleSystem.Play();
                timer = 0f;
            }
        }

        /// <summary>
        /// Updates the dissolve threshold on all materials using MaterialPropertyBlock.
        /// </summary>
        private void UpdateDissolveEffect()
        {
            float normalizedTime = Mathf.InverseLerp(0f, effectDuration, timer);
            float dissolveValue = fadeInCurve.Evaluate(normalizedTime);

            // Use MaterialPropertyBlock for better performance (no material instantiation)
            objectRenderer.GetPropertyBlock(propertyBlock);
            propertyBlock.SetFloat(DissolveThresholdProperty, dissolveValue);
            objectRenderer.SetPropertyBlock(propertyBlock);
        }

        /// <summary>
        /// Resets the effect to its initial state.
        /// </summary>
        public void ResetEffect()
        {
            timer = 0f;
            if (particleSystem != null)
            {
                particleSystem.Stop();
                particleSystem.Play();
            }
        }
    }
}
