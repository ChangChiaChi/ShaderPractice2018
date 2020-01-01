Shader "TA-Shader/PoseEffect/Blood"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NoiseOffsets("NoiseOffset", 2D) = "white" {}
		_Color("Color", Color) = (1.0,1.0,1.0,1.0)
		_NoiseSize("NoiseSize", float) = 1.0
		_NoisePos("NoisePos", Vector) = (1.0,1.0,1.0,1.0)
		_Fade("Fade", Range(0.0,5.0)) = 1.0 // sliders

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float4 vertex : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseOffsets;
			float4 _NoiseOffsets_ST;
			fixed4 _Color;
			float _NoiseSize;
			float4 _NoisePos;
			float _Fade;

			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.vertex = fixed4(v.vertex.x * 2, v.vertex.y * 2, 0, 1);
				return o;
			}

			float noise(float3 x)
			{
				x *= 4.0;
				float3 p = floor(x);
				float3 f = frac(x);
				f = f * f*(3.0 - 2.0*f);
				float2 uv = (p.xy + float2(37.0, 17.0)*p.z) + f.xy;
				float2 rg = tex2D(_NoiseOffsets, (uv + 0.5) / 256.0).yx;
				return lerp(rg.x, rg.y, f.z);
			}

			float noise_sum(float3 p)
			{
				float f = 0.0;
				f += (1.0000 * noise(p)); p = 2.0 * p;
				f += (0.5000 * noise(p)); p = 2.0 * p;
				f += (0.2500 * noise(p)); p = 2.0 * p;
				f += (0.1250 * noise(p)); p = 2.0 * p;

				//f += 0.06255 * noise(p); 
				return f;
			}
			
			fixed4 frag(v2f i) :SV_Target
			{
				fixed4 c;
				c = _Color * noise_sum(i.pos * _NoiseSize + _NoisePos);
				if (c.a <= _Fade)
				{
					c.a = 0.0f;
				}
				else
				{
					c.a = _Fade;
				}
				return c;
			}
			ENDCG
		}
	}
}
