// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
//Reference http://zhi-yuan-chenge.blogspot.com/2016/11/unityoutline.html
Shader "TA-Shader/BlinnShading/DNS_Outline"
{
	Properties
	{	
		//BlinnShading
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "White"{}
		_BumpMap("Normal Map", 2D) = "bump"{}
		_BumpScale("Bump Scale", Float) = 1.0
		_SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
		_Specular("Specular", 2D) = "White"{}
		_Gloss("Gloss", Range(8.0, 256)) = 20
		//Outline
		_OutlineColor("Outline Color", Color) = (0,1,0,1)
		_Outline("Outline Width", Range(0.002, 1)) = 0.01
	}

		SubShader{
			Tags{ "RenderType" = "Opaque" }
			//Outline

			Pass{
				Name "Outline"
				Tags{ "LightMode" = "Always" }

				Cull Front
				ZWrite On
				ColorMask RGB
				Blend SrcAlpha OneMinusSrcAlpha

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				uniform float _Outline;
				uniform float4 _OutlineColor;

				struct appdata {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};
				float4 vert(appdata v) : SV_POSITION{
					float4 pos = UnityObjectToClipPos(v.vertex);
					float3 norm = mul((float3x3)UNITY_MATRIX_MV, v.normal);
					norm.x *= UNITY_MATRIX_P[0][0];
					norm.y *= UNITY_MATRIX_P[1][1];
					pos.xy += norm.xy * pos.z * _Outline;
					return pos;
				}

				float4 frag() : SV_TARGET{
					return  _OutlineColor;
				}
				ENDCG
			}
		UsePass "TA-Shader/BlinnShading/DNS/BASE"
	}
	Fallback "Diffuse"
}