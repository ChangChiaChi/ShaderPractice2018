using UnityEngine;

namespace TAShader
{
    /// <summary>
    /// Base class for post-processing effects.
    /// Provides common functionality for shader-based image effects.
    /// </summary>
    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    public class PostEffectsBase : MonoBehaviour
    {
        /// <summary>
        /// Checks if the platform supports required features.
        /// </summary>
        protected void CheckResources()
        {
            if (!CheckSupport())
            {
                NotSupported();
            }
        }

        /// <summary>
        /// Verifies platform support for image effects and render textures.
        /// </summary>
        protected virtual bool CheckSupport()
        {
            if (!SystemInfo.supportsImageEffects)
            {
                Debug.LogWarning("[PostEffectsBase] This platform does not support image effects.");
                return false;
            }

            return true;
        }

        /// <summary>
        /// Called when the platform doesn't support required features.
        /// </summary>
        protected virtual void NotSupported()
        {
            enabled = false;
        }

        protected virtual void Start()
        {
            CheckResources();
        }

        /// <summary>
        /// Creates or retrieves a material for the specified shader.
        /// </summary>
        /// <param name="shader">The shader to use for the material.</param>
        /// <param name="material">Reference to store the created material.</param>
        /// <returns>The created or existing material, or null if shader is not supported.</returns>
        protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
        {
            if (shader == null)
            {
                return null;
            }

            if (shader.isSupported && material != null && material.shader == shader)
            {
                return material;
            }

            if (!shader.isSupported)
            {
                Debug.LogWarning($"[PostEffectsBase] Shader '{shader.name}' is not supported on this platform.");
                return null;
            }

            material = new Material(shader)
            {
                hideFlags = HideFlags.DontSave
            };

            return material;
        }
    }
}
