// Reference: http://zhi-yuan-chenge.blogspot.com/2016/11/unityoutline.html
// Blinn-Phong shading with outline effect
Shader "TA-Shader/BlinnShading/DNS_Outline"
{
    Properties
    {
        // Blinn Shading
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "White"{}
        _BumpMap("Normal Map", 2D) = "bump"{}
        _BumpScale("Bump Scale", Float) = 1.0
        _SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
        _Specular("Specular", 2D) = "White"{}
        _Gloss("Gloss", Range(8.0, 256)) = 20
        // Outline
        _OutlineColor("Outline Color", Color) = (0, 1, 0, 1)
        _Outline("Outline Width", Range(0.002, 1)) = 0.01
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        // Outline Pass
        Pass
        {
            Name "Outline"
            Tags { "LightMode" = "Always" }

            Cull Front
            ZWrite On
            ColorMask RGB
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            uniform float _Outline;
            uniform float4 _OutlineColor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            float4 vert(appdata v) : SV_POSITION
            {
                float4 pos = UnityObjectToClipPos(v.vertex);

                // Transform normal to view space using inverse transpose matrix
                float3 viewNormal = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));

                // Apply projection matrix scaling to normalize screen-space offset
                float2 projectedNormal = mul((float2x2)UNITY_MATRIX_P, viewNormal.xy);

                // Offset position along projected normal
                pos.xy += projectedNormal * pos.z * _Outline;
                return pos;
            }

            float4 frag() : SV_TARGET
            {
                return _OutlineColor;
            }
            ENDCG
        }

        UsePass "TA-Shader/BlinnShading/DNS/BASE"
    }
    Fallback "Diffuse"
}