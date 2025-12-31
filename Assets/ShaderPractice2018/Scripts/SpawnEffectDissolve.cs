using UnityEngine;

/// <summary>
/// Controls a dissolve spawn effect that cycles through a dissolve animation
/// using particle systems and material property changes.
/// </summary>
public class SpawnEffectDissolve : MonoBehaviour
{
    private static readonly int DissolveThresholdProperty = Shader.PropertyToID("_DissolveThreshold");

    [Header("Effect Timing")]
    public float spawnEffectTime = 2;
    public float pause = 1;

    [Header("Animation")]
    public AnimationCurve fadeIn;

    private ParticleSystem ps;
    private float timer = 0;
    private Renderer _renderer;
    private MaterialPropertyBlock propertyBlock;

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
        _renderer = GetComponent<Renderer>();
        if (_renderer == null)
        {
            Debug.LogError($"[SpawnEffectDissolve] No Renderer found on {gameObject.name}.");
            return false;
        }

        ps = GetComponentInChildren<ParticleSystem>();
        if (ps == null)
        {
            Debug.LogError($"[SpawnEffectDissolve] No ParticleSystem found in children of {gameObject.name}.");
            return false;
        }

        // Initialize property block for efficient material property updates
        propertyBlock = new MaterialPropertyBlock();

        // Stop particle system before configuring duration
        ps.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);

        // Configure particle system duration
        var main = ps.main;
        main.duration = spawnEffectTime;

        // Start the effect
        ps.Play();

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
        if (timer < spawnEffectTime + pause)
        {
            timer += Time.deltaTime;
        }
        else
        {
            ps.Play();
            timer = 0;
        }
    }

    /// <summary>
    /// Updates the dissolve threshold on all materials using MaterialPropertyBlock.
    /// </summary>
    private void UpdateDissolveEffect()
    {
        float dissolveValue = fadeIn.Evaluate(Mathf.InverseLerp(0, spawnEffectTime, timer));

        // Use MaterialPropertyBlock for better performance (no material instantiation)
        _renderer.GetPropertyBlock(propertyBlock);
        propertyBlock.SetFloat(DissolveThresholdProperty, dissolveValue);
        _renderer.SetPropertyBlock(propertyBlock);
    }

    /// <summary>
    /// Resets the effect to its initial state.
    /// </summary>
    public void ResetEffect()
    {
        timer = 0;
        if (ps != null)
        {
            ps.Stop();
            ps.Play();
        }
    }
}
