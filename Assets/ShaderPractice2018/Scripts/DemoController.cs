using UnityEngine;
using TMPro;

/// <summary>
/// Controls the demo scene, switching between different shader effect demonstrations.
/// </summary>
public class DemoController : MonoBehaviour
{
    /// <summary>
    /// Enumeration of available shader demo effects.
    /// </summary>
    public enum DemoType
    {
        None = 0,
        Dissolve = 1,
        FlowLight = 2,
        Outline = 3,
        RimLight = 4,
        MotionBlur = 5,
        Mirror = 6,
        Glass = 7,
        Bloom = 8
    }

    [Header("Demo Settings")]
    public int demoNum = 0;

    [Header("Character References")]
    public GameObject[] _Character;

    [Header("Post-Processing Effects")]
    public TAShader.Bloom _bloom;
    public TAShader.MotionBlur _MotionBlur;

    [Header("Animation")]
    public Animator _Animator;

    [Header("UI References")]
    public TextMeshProUGUI _textMesh;
    public GameObject[] _btn;

    private readonly string[] _title =
    {
        "1. Dissolve Effect",
        "2. Flow Light Effect",
        "3. Outline",
        "4. Rim Light",
        "5. Motion Blur",
        "6. Mirror Effect",
        "7. Glass Effect",
        "8. Bloom Effect"
    };

    private void Start()
    {
        if (!ValidateReferences())
        {
            enabled = false;
            return;
        }

        InitializeDemo(false);
        SetDemo(demoNum);
    }

    /// <summary>
    /// Validates that all required references are assigned.
    /// </summary>
    private bool ValidateReferences()
    {
        if (_Character == null || _Character.Length == 0)
        {
            Debug.LogError("[DemoController] Characters array is not assigned or empty.");
            return false;
        }

        if (_bloom == null)
        {
            Debug.LogError("[DemoController] Bloom effect is not assigned.");
            return false;
        }

        if (_MotionBlur == null)
        {
            Debug.LogError("[DemoController] Motion blur effect is not assigned.");
            return false;
        }

        if (_Animator == null)
        {
            Debug.LogError("[DemoController] Character animator is not assigned.");
            return false;
        }

        if (_textMesh == null)
        {
            Debug.LogError("[DemoController] Title text is not assigned.");
            return false;
        }

        if (_btn == null || _btn.Length < 2)
        {
            Debug.LogError("[DemoController] Navigation buttons are not properly assigned.");
            return false;
        }

        return true;
    }

    /// <summary>
    /// Initializes demo state by enabling/disabling all effects and characters.
    /// </summary>
    private void InitializeDemo(bool isEnabled)
    {
        _bloom.enabled = isEnabled;
        _MotionBlur.enabled = isEnabled;

        foreach (var character in _Character)
        {
            if (character != null)
            {
                character.SetActive(isEnabled);
            }
        }
    }

    /// <summary>
    /// Sets the current demo to display.
    /// </summary>
    private void SetDemo(int demo)
    {
        if (demo == 0)
            return;

        int demoIndex = demo - 1;

        // Update navigation button visibility
        UpdateNavigationButtons(demo);

        // Activate the corresponding character
        if (demoIndex >= 0 && demoIndex < _Character.Length)
        {
            _Character[demoIndex].SetActive(true);
        }

        // Update title text
        if (demoIndex >= 0 && demoIndex < _title.Length)
        {
            _textMesh.SetText(_title[demoIndex]);
        }

        // Configure demo-specific effects
        ConfigureEffects((DemoType)demo);
    }

    /// <summary>
    /// Updates the visibility of navigation buttons based on current demo.
    /// </summary>
    private void UpdateNavigationButtons(int demo)
    {
        bool showPrevious = demo != (int)DemoType.Dissolve;
        bool showNext = demo != _Character.Length;

        _btn[0].SetActive(showPrevious);
        _btn[1].SetActive(showNext);
    }

    /// <summary>
    /// Configures effects specific to each demo type.
    /// </summary>
    private void ConfigureEffects(DemoType demo)
    {
        // Reset all effects
        _MotionBlur.enabled = false;
        _bloom.enabled = false;
        _Animator.SetBool("isMove", false);
        _Animator.SetBool("isGlass", false);

        // Enable demo-specific effects
        switch (demo)
        {
            case DemoType.MotionBlur:
                _MotionBlur.enabled = true;
                _Animator.SetBool("isMove", true);
                break;

            case DemoType.Glass:
                _Animator.SetBool("isGlass", true);
                break;

            case DemoType.Bloom:
                _bloom.enabled = true;
                break;
        }
    }

    /// <summary>
    /// Navigates to the previous demo. Called by UI button.
    /// </summary>
    public void PreDemo()
    {
        if (demoNum <= (int)DemoType.Dissolve)
            return;

        InitializeDemo(false);
        demoNum--;
        SetDemo(demoNum);
    }

    /// <summary>
    /// Navigates to the next demo. Called by UI button.
    /// </summary>
    public void NextDemo()
    {
        if (demoNum >= _Character.Length)
            return;

        InitializeDemo(false);
        demoNum++;
        SetDemo(demoNum);
    }
}
