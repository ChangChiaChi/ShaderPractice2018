using UnityEngine;
using UnityEngine.Serialization;
using TMPro;

namespace ShaderPractice
{
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
        [FormerlySerializedAs("demoNum")]
        [SerializeField] private DemoType currentDemo = DemoType.None;

        [Header("Character References")]
        [FormerlySerializedAs("_Character")]
        [SerializeField] private GameObject[] characters;

        [Header("Post-Processing Effects")]
        [FormerlySerializedAs("_bloom")]
        [SerializeField] private TAShader.Bloom bloomEffect;
        [FormerlySerializedAs("_MotionBlur")]
        [SerializeField] private TAShader.MotionBlur motionBlurEffect;

        [Header("Animation")]
        [FormerlySerializedAs("_Animator")]
        [SerializeField] private Animator characterAnimator;

        [Header("UI References")]
        [FormerlySerializedAs("_textMesh")]
        [SerializeField] private TextMeshProUGUI titleText;
        [FormerlySerializedAs("_btn")]
        [SerializeField] private GameObject[] navigationButtons;

        private readonly string[] demoTitles =
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
            SetDemo(currentDemo);
        }

        /// <summary>
        /// Validates that all required references are assigned.
        /// </summary>
        private bool ValidateReferences()
        {
            if (characters == null || characters.Length == 0)
            {
                Debug.LogError("[DemoController] Characters array is not assigned or empty.");
                return false;
            }

            if (bloomEffect == null)
            {
                Debug.LogError("[DemoController] Bloom effect is not assigned.");
                return false;
            }

            if (motionBlurEffect == null)
            {
                Debug.LogError("[DemoController] Motion blur effect is not assigned.");
                return false;
            }

            if (characterAnimator == null)
            {
                Debug.LogError("[DemoController] Character animator is not assigned.");
                return false;
            }

            if (titleText == null)
            {
                Debug.LogError("[DemoController] Title text is not assigned.");
                return false;
            }

            if (navigationButtons == null || navigationButtons.Length < 2)
            {
                Debug.LogError("[DemoController] Navigation buttons are not properly assigned.");
                return false;
            }

            return true;
        }

        /// <summary>
        /// Initializes demo state by enabling/disabling all effects and characters.
        /// </summary>
        private void InitializeDemo(bool enabled)
        {
            bloomEffect.enabled = enabled;
            motionBlurEffect.enabled = enabled;

            foreach (var character in characters)
            {
                if (character != null)
                {
                    character.SetActive(enabled);
                }
            }
        }

        /// <summary>
        /// Sets the current demo to display.
        /// </summary>
        private void SetDemo(DemoType demo)
        {
            if (demo == DemoType.None)
                return;

            int demoIndex = (int)demo - 1;

            // Update navigation button visibility
            UpdateNavigationButtons(demo);

            // Activate the corresponding character
            if (demoIndex >= 0 && demoIndex < characters.Length)
            {
                characters[demoIndex].SetActive(true);
            }

            // Update title text
            if (demoIndex >= 0 && demoIndex < demoTitles.Length)
            {
                titleText.SetText(demoTitles[demoIndex]);
            }

            // Configure demo-specific effects
            ConfigureEffects(demo);
        }

        /// <summary>
        /// Updates the visibility of navigation buttons based on current demo.
        /// </summary>
        private void UpdateNavigationButtons(DemoType demo)
        {
            bool showPrevious = demo != DemoType.Dissolve;
            bool showNext = (int)demo != characters.Length;

            navigationButtons[0].SetActive(showPrevious);
            navigationButtons[1].SetActive(showNext);
        }

        /// <summary>
        /// Configures effects specific to each demo type.
        /// </summary>
        private void ConfigureEffects(DemoType demo)
        {
            // Reset all effects
            motionBlurEffect.enabled = false;
            bloomEffect.enabled = false;
            characterAnimator.SetBool("isMove", false);
            characterAnimator.SetBool("isGlass", false);

            // Enable demo-specific effects
            switch (demo)
            {
                case DemoType.MotionBlur:
                    motionBlurEffect.enabled = true;
                    characterAnimator.SetBool("isMove", true);
                    break;

                case DemoType.Glass:
                    characterAnimator.SetBool("isGlass", true);
                    break;

                case DemoType.Bloom:
                    bloomEffect.enabled = true;
                    break;
            }
        }

        /// <summary>
        /// Navigates to the previous demo.
        /// </summary>
        public void PreviousDemo()
        {
            if (currentDemo <= DemoType.Dissolve)
                return;

            InitializeDemo(false);
            currentDemo--;
            SetDemo(currentDemo);
        }

        /// <summary>
        /// Navigates to the next demo.
        /// </summary>
        public void NextDemo()
        {
            if ((int)currentDemo >= characters.Length)
                return;

            InitializeDemo(false);
            currentDemo++;
            SetDemo(currentDemo);
        }
    }
}
