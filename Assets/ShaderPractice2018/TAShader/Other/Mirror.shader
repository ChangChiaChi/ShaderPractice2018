﻿Shader "TA-Shader/Mirror"
{
	Properties{
		_MainTex("Albedo(RGB)",2D)="white"{}
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			struct a2v
			{
				fixed4 vertex:POSITION;
				fixed4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				fixed4 pos:SV_POSITION;
				fixed4 uv:TEXCOORD0;
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.uv=v.texcoord;
				o.uv.x=1-o.uv.x;
				return o;
			}

			fixed4 frag(v2f i):SV_Target
			{
				return tex2D(_MainTex,i.uv);
			}

		ENDCG
		}
	}
}