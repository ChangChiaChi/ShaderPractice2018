// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "TA-Shader/Basic/Outline"
{
	Properties
	{
		//Outline
		_OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
		_OutlineWidth("Outline Width", Range(0.0, 1.0)) = .005
	}

		SubShader
		{
			Pass
			{
				Name "OUTLINE"
				Cull front
				ZWrite Off
				ZTest Always
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				struct a2v
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};

				struct v2f
				{
					float4 pos : POSITION;
				};

				float _OutlineWidth;
				float4 _OutlineColor;

				v2f vert(a2v v)
				{
					v2f o;
					v.vertex.xyz += v.normal * _OutlineWidth;
					o.pos = UnityObjectToClipPos(v.vertex);

					return o;
				}

				half4 frag(v2f i) : COLOR
				{
					return _OutlineColor;
				}
				ENDCG
			}

		}
}