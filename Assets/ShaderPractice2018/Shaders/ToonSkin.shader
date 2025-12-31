// Toon Skin Shader with Subsurface Scattering (SSS) effect
// Uses a simplified SSS approximation for skin rendering
Shader "Custom/ToonSkin"
{
    Properties
    {
        [Header(Base Colors)]
        _Color("Color", Color) = (1, 1, 1, 1)
        _InternalColor("Internal Color (SSS)", Color) = (1, 1, 1, 1)
        _SpecularColor("Specular Color", Color) = (1, 1, 1, 1)

        [Header(Textures)]
        _MainTex("Albedo (RGB) SSS (A)", 2D) = "white" {}
        _SpecGloss("Specular (RGB) Glossiness (A)", 2D) = "white" {}
        _BumpMap("Bumpmap", 2D) = "bump" {}
        _DetailBumpMap("Detail Bumpmap", 2D) = "bump" {}

        [Header(Surface Properties)]
        _SSS("SSS Intensity", Range(0, 1)) = 1
        _Glossiness("Smoothness", Range(0, 1)) = 0.5
        _Specular("Specular", Range(0, 2)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #include "UnityPBSLighting.cginc"

        #pragma surface surf SimpleSSS fullforwardshadows
        #pragma target 3.0

        // Texture samplers
        sampler2D _MainTex;
        sampler2D _SpecGloss;
        sampler2D _BumpMap;
        sampler2D _DetailBumpMap;

        // Surface input structure
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv_DetailBumpMap;
        };

        // Material properties
        half _Glossiness;
        half _Specular;
        fixed4 _Color;
        fixed4 _InternalColor;
        fixed4 _SpecularColor;
        half _SSS;

        // GPU Instancing support
        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        /// <summary>
        /// Simplified subsurface scattering approximation.
        /// Simulates light transmission through translucent materials like skin.
        /// </summary>
        float3 SubsurfaceShadingSimple(float3 diffColor, float3 normal, float3 viewDir,
                                        float3 thickness, float3 lightDir, float3 lightColor)
        {
            half3 vLTLight = lightDir + normal;
            half fLTDot = pow(saturate(dot(viewDir, -vLTLight)), 3.5) * 1.5;
            half3 fLT = (fLTDot + 1.2) * thickness;
            return diffColor * ((lightColor * fLT) * 0.4);
        }

        /// <summary>
        /// Custom lighting function with SSS support.
        /// </summary>
        half4 LightingSimpleSSS(SurfaceOutputStandardSpecular s, half3 viewDir, UnityGI gi)
        {
            s.Normal = normalize(s.Normal);

            // Energy conservation between diffuse and specular
            half oneMinusReflectivity;
            s.Albedo = EnergyConservationBetweenDiffuseAndSpecular(s.Albedo, s.Specular, oneMinusReflectivity);

            // Pre-multiply alpha for physically correct transparency
            half outputAlpha;
            s.Albedo = PreMultiplyAlpha(s.Albedo, 1.0f, oneMinusReflectivity, outputAlpha);

            // Standard PBR lighting
            half4 c = UNITY_BRDF_PBS(s.Albedo, s.Specular, oneMinusReflectivity, s.Smoothness,
                                      s.Normal, viewDir, gi.light, gi.indirect);

            // Add subsurface scattering contribution
            c.rgb += SubsurfaceShadingSimple(_InternalColor, s.Normal, viewDir,
                                              s.Alpha * _SSS, gi.light.dir, gi.light.color);

            c.a = outputAlpha;
            return c;
        }

        /// <summary>
        /// Global illumination setup for the SSS lighting model.
        /// </summary>
        inline void LightingSimpleSSS_GI(SurfaceOutputStandardSpecular s, UnityGIInput data, inout UnityGI gi)
        {
            #if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
                gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
            #else
                Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, s.Specular);
                gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal, g);
            #endif
        }

        /// <summary>
        /// Surface shader function.
        /// </summary>
        void surf(Input IN, inout SurfaceOutputStandardSpecular o)
        {
            // Sample textures
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            fixed4 s = tex2D(_SpecGloss, IN.uv_MainTex);

            // Set surface outputs
            o.Albedo = c.rgb;
            o.Normal = BlendNormals(
                UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap)),
                UnpackNormal(tex2D(_DetailBumpMap, IN.uv_DetailBumpMap))
            );
            o.Specular = _Specular * s.rgb * _SpecularColor.rgb;
            o.Smoothness = _Glossiness * s.a;
            o.Alpha = c.a;
        }
        ENDCG
    }

    FallBack "Standard"
}
