# Shader Practice Collection

A comprehensive collection of shader effects for Unity, featuring character rendering, post-processing, and visual effects.

## Requirements

- **Unity Version**: 2022.3.62f1 or higher (LTS recommended)
- **Render Pipeline**: Built-in Render Pipeline
- **Shader Model**: 3.0+

## Features

### Character Shaders

| Shader | Description |
|--------|-------------|
| **ToonSkin** | Toon-style skin shader with Subsurface Scattering (SSS) approximation |
| **SculptedHair** | Anisotropic hair shader for realistic hair highlights |
| **EyeBallsHD** | High-definition eye shader with reflection and refraction |

### Blinn-Phong Shading Series

| Shader | Description |
|--------|-------------|
| **DNS** | Diffuse-Normal-Specular base shader |
| **DNS_Dissolve** | DNS with dissolve effect |
| **DNS_Outline** | DNS with outline effect |
| **Dissolve** | Standalone dissolve effect |

### Visual Effects

| Shader | Description |
|--------|-------------|
| **Outline** | Object outline/silhouette effect |
| **RimLight** | Edge/rim lighting effect |
| **RimLightWithAnim** | Animated rim light with scrolling |
| **Glass** | Transparent glass material |
| **Mirror** | Planar mirror reflection |

### Post-Processing Effects

| Shader | Description |
|--------|-------------|
| **Bloom** | HDR bloom/glow effect |
| **GaussianBlur** | Gaussian blur filter |
| **MotionBlur** | Camera motion blur |

## Installation

1. Import the package into your Unity project
2. Shaders will be available under:
   - `Custom/` - Character shaders
   - `TA-Shader/BlinnShading/` - Blinn-Phong series
   - `TA-Shader/PoseEffect/` - Post-processing effects
   - `TA-Shader/Other/` - Visual effects

## Quick Start

### Using Character Shaders

1. Create a new Material
2. Select shader: `Custom/ToonSkin`
3. Assign your textures:
   - **Albedo**: Base color texture (Alpha channel for SSS mask)
   - **Specular**: Specular map (RGB) with glossiness (A)
   - **Bumpmap**: Normal map
4. Adjust SSS Intensity for skin translucency

### Using Post-Processing Effects

1. Add the effect script to your Main Camera:
   ```csharp
   using TAShader;

   // Add component
   gameObject.AddComponent<Bloom>();
   ```
2. Assign the corresponding shader in the Inspector
3. Adjust parameters as needed

## Demo Scene

Open `Assets/Scenes/Start.unity` to see all effects in action.

### Demo Controls
- **Previous/Next buttons**: Navigate between effects
- 8 demonstration modes showing different shader capabilities

## Shader Parameters Reference

### ToonSkin Shader

| Parameter | Type | Description |
|-----------|------|-------------|
| Color | Color | Base color tint |
| Internal Color | Color | SSS internal color (skin undertone) |
| Specular Color | Color | Specular highlight color |
| SSS Intensity | Float (0-1) | Subsurface scattering strength |
| Smoothness | Float (0-1) | Surface smoothness |
| Specular | Float (0-2) | Specular intensity |

### DNS Shader

| Parameter | Type | Description |
|-----------|------|-------------|
| Color Tint | Color | Base color multiplier |
| Main Tex | Texture2D | Albedo/diffuse texture |
| Normal Map | Texture2D | Tangent-space normal map |
| Bump Scale | Float | Normal map intensity |
| Specular Map | Texture2D | Specular intensity mask |
| Gloss | Float (8-256) | Specular power/sharpness |

### Bloom Effect

| Parameter | Type | Description |
|-----------|------|-------------|
| Luminance Threshold | Float | Brightness threshold for bloom |
| Blur Size | Float | Bloom spread amount |
| Iterations | Int | Blur quality iterations |

## Render Pipeline Compatibility

| Pipeline | Status |
|----------|--------|
| Built-in RP | Fully Supported |
| URP | Not Supported |
| HDRP | Not Supported |

> **Note**: This package is designed for the Built-in Render Pipeline. Surface Shaders used in character shaders are not compatible with URP/HDRP.

## Project Structure

```
Assets/
└── ShaderPractice2018/
    ├── Shaders/           # Character shaders (ToonSkin, Hair, Eyes)
    ├── TAShader/          # Technical Art shaders
    │   ├── Basic/         # Base classes and outline
    │   ├── BlinnShading/  # Blinn-Phong shader series
    │   ├── Other/         # Glass, Mirror, RimLight
    │   └── PoseEffect/    # Post-processing effects
    ├── Scripts/           # C# control scripts
    ├── Materials/         # Pre-configured materials
    └── Prefab/            # Ready-to-use prefabs
```

## Scripting API

### Namespace: ShaderPractice

```csharp
using ShaderPractice;

// Demo controller for switching effects
DemoController controller;
controller.NextDemo();
controller.PreviousDemo();

// Dissolve effect control
SpawnEffectDissolve dissolve;
dissolve.ResetEffect();
```

### Namespace: TAShader

```csharp
using TAShader;

// Post-processing base class
public class MyEffect : PostEffectsBase
{
    protected override void Start()
    {
        base.Start();
        // Your initialization
    }
}
```

## Performance Notes

- All shaders target Shader Model 3.0 for broad compatibility
- Post-processing effects use optimized single-pass rendering where possible
- MaterialPropertyBlock used for efficient runtime property updates

## Troubleshooting

### Shader appears pink/magenta
- Ensure you're using Built-in Render Pipeline
- Check that all required textures are assigned

### Post-processing not working
- Verify the camera has the effect component attached
- Check Console for shader compilation errors
- Ensure `SystemInfo.supportsImageEffects` returns true

### Outline appears incorrect
- Adjust Outline Width parameter
- Ensure model has proper normals

## Version History

- **2.0.0** - Unity 2022.3 compatibility update
  - Updated deprecated shader APIs
  - Improved code formatting and documentation
  - Added namespace encapsulation
  - Enhanced error handling

- **1.0.0** - Initial release (Unity 2018.2.9f1)

## License

This package is provided for educational and commercial use. Please ensure you have proper licensing for any third-party assets used in your projects.

## Support

For questions and support:
- GitHub Issues: [Report an issue](https://github.com/your-repo/issues)
- Email: your-email@example.com

---

Made with Unity
