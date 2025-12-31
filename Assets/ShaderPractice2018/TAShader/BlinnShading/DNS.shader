// Diffuse-Normal-Specular (DNS) Shader using Blinn-Phong lighting model
// Supports normal mapping and specular highlights
Shader "TA-Shader/BlinnShading/DNS"
{
    Properties
    {
        [Header(Base)]
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white" {}

        [Header(Normal Mapping)]
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Bump Scale", Float) = 1.0

        [Header(Specular)]
        _SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
        _Specular("Specular Map", 2D) = "white" {}
        _Gloss("Gloss", Range(8.0, 256)) = 256
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            Name "BASE"
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            // Material properties
            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            sampler2D _Specular;
            float4 _Specular_ST;
            fixed4 _SpecularColor;
            float _Gloss;

            // Vertex input structure
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            // Vertex to fragment structure
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            v2f vert(appdata v)
            {
                v2f o;

                // Transform vertex to clip space
                o.pos = UnityObjectToClipPos(v.vertex);

                // Calculate texture coordinates
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                // Calculate tangent space transformation
                TANGENT_SPACE_ROTATION;

                // Transform light and view directions to tangent space
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Normalize interpolated directions
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);

                // Sample and unpack normal map
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal = UnpackNormal(packedNormal);
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                // Sample albedo texture
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;

                // Calculate ambient lighting
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                // Calculate diffuse lighting (Lambert)
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

                // Sample specular map
                fixed3 specularMap = tex2D(_Specular, i.uv.xy).rgb;

                // Calculate Blinn-Phong specular
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb *
                                  pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

                // Combine lighting components
                fixed3 color = ambient + diffuse + saturate(specular * specularMap);

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
