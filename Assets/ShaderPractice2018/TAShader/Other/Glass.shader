Shader "TA-Shader/Glass"
{
	Properties
	{
		_NormalMap("Normal Map", 2D) = "bump" {}
		_Distortion("Distortion", Range(0, 500)) = 50
		//RimLight
		//_RimTex("Rim Tex", 2D) = "white" {}
		_RimColor("RimColor", Color) = (1, 1, 1, 1)
		_EdgeScale("Edge Scale", Float) = 1.0
		_RimScale("Rim Scale", Float) = 1.0
	}

		SubShader
		{
			Tags
			{
				"Queue" = "Transparent"
				"RenderType" = "Transparent"
			}

			GrabPass { "_GrabTex" }

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				sampler2D _GrabTex;
				float4 _GrabTex_TexelSize;
				sampler2D _NormalMap;
				float _Distortion;
				//RimLight
				//sampler2D _RimTex;
				fixed4  _RimColor;
				float _Gloss;
				float _EdgeScale;
				float _RimScale;
				struct appdata
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float4 texcoord : TEXCOORD0;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float2 uv : TEXCOORD0;
					float4 scrPos : TEXCOORD1;


					float3 worldNormal : TEXCOORD2;
					float3 worldPos : TEXCOORD3;
				};

				v2f vert(appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = v.texcoord;
					o.scrPos = ComputeGrabScreenPos(o.pos);

					o.worldNormal = UnityObjectToWorldNormal(v.normal);
					o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
					return o;
				}

				fixed4 frag(v2f i) : SV_TARGET
				{
					float3 bump = UnpackNormal(tex2D(_NormalMap, i.uv));
					float2 offset = bump.xy * _GrabTex_TexelSize.xy * _Distortion;

					//RimLight
					fixed3 worldNormal = normalize(i.worldNormal);
					fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
					fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));

					
					half rim = 1.0 - saturate(dot(normalize(viewDir), i.worldNormal));
					fixed3 emission = _RimColor.rgb * pow(rim, _EdgeScale);
					//fixed rim_curve = tex2D(_RimTex, fixed2(i.uv.x, i.uv.y)).r;
					//emission *= rim_curve;

					fixed3 albedo = tex2D(_GrabTex, (i.scrPos.xy + offset) / i.scrPos.w) + emission * _RimScale;
					return fixed4(albedo, 1.0f);
				}

				ENDCG
			}
		}
}