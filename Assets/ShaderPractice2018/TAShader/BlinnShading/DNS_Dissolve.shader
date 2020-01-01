Shader "TA-Shader/BlinnShading/DNS_Dissolve"
{
	Properties{
		//BlinnShading
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "White"{}
		_BumpMap("Normal Map", 2D) = "bump"{}
		_BumpScale("Bump Scale", Float) = 1.0
		_SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
		_Specular("Specular", 2D) = "White"{}
		_Gloss("Gloss", Range(8.0, 256)) = 20
			//Dissolve
			_DissolveColor("Dissolve Color", Color) = (0,0,0,0)
			_DissolveEdgeColor("Dissolve Edge Color", Color) = (1,1,1,1)
			_DissolveMap("DissolveMap", 2D) = "white"{}
			_DissolveThreshold("DissolveThreshold", Range(0,1)) = 0
			_ColorFactor("ColorFactor", Range(0,1)) = 0.7
			_DissolveEdge("DissolveEdge", Range(0,1)) = 0.8

	}

		SubShader{
			Pass
			{
				//BlinnShading
				Tags{"LightMode" = "ForwardBase"}
				Cull Off
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "Lighting.cginc"

				//BlinnShading
				fixed4		_Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _BumpMap;
				float4 _BumpMap_ST;
				float _BumpScale;
				sampler2D _Specular;
				float4 _Specular_ST;
				fixed4 _SpecularColor;
				float _Gloss;

				//Dissolve
				fixed4	_DissolveColor;
				fixed4	_DissolveEdgeColor;
				sampler2D _DissolveMap;
				float4 _DissolveMap_ST;
				float _DissolveThreshold;
				float _ColorFactor;
				float _DissolveEdge;

				struct a2v {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float4 tangent:TANGENT;
					float4 texcoord:TEXCOORD0;
				};
				struct v2f {
						float4 pos:SV_POSITION;
						float4 uv:TEXCOORD0;
						float3 lightDir:TEXCOORD1;
						float3 viewDir:TEXCOORD2;
					};
				v2f vert(a2v v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
					TANGENT_SPACE_ROTATION;

					o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
					o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
					return o;

				}

				fixed4 frag(v2f i) :SV_Target
				{
					fixed4 dissolveValue = tex2D(_DissolveMap, i.uv);
				//小於則丟棄
				clip(dissolveValue.r - _DissolveThreshold);
				//if (dissolveValue.r < _DissolveThreshold)
				//{
				//	discard;
				//}


				//BlinnShading============
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
				fixed3 tangentNormal;

				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

				fixed3 specularMap = tex2D(_Specular, i.uv).rgb;


				//BlinnShading Function============
				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

				fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
				//BlinnShadinfig Function============

				fixed3 color = ambient + diffuse + clamp(specular * (specularMap),0,1);
				//BlinnShading============

				//Dissolve==================
				//Reference https://blog.csdn.net/puppet_master/article/details/72455945
				//优化版本，尽量不在shader中用分支判断的版本,但是代码很难理解啊....
				float percentage = _DissolveThreshold / dissolveValue.r;
				//如果当前百分比 - 颜色权重 - 边缘颜色
				float lerpEdge = sign(percentage - _ColorFactor - _DissolveEdge);
				//貌似sign返回的值还得saturate一下，否则是一个很奇怪的值
				fixed3 edgeColor = lerp(_DissolveEdgeColor.rgb, _DissolveColor.rgb, saturate(lerpEdge));
				//最终输出颜色的lerp值
				float lerpOut = sign(percentage - _ColorFactor);
				//最终颜色在原颜色和上一步计算的颜色之间差值（其实经过saturate（sign（..））的lerpOut应该只能是0或1）
				fixed3 colorOut = lerp(color, edgeColor, saturate(lerpOut));
				return fixed4(colorOut, 1);
			}
			ENDCG
		}

		Pass{
			Tags {"LightMode" = "ShadowCaster"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			sampler2D _DissolveMap;
			float4 _DissolveMap_ST;
			float _DissolveThreshold;
			struct v2f {
			V2F_SHADOW_CASTER;
						float2 uvBurnMap:TEXCOORD1;
			};
		v2f vert(appdata_base v)
		{
			v2f o;
			TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
			o.uvBurnMap = TRANSFORM_TEX(v.texcoord, _DissolveMap);
			return o;
		}

		fixed4 frag(v2f i) :SV_Target{
			fixed3 burn = tex2D(_DissolveMap, i.uvBurnMap).rgb;
			clip(burn.r - _DissolveThreshold);
		SHADOW_CASTER_FRAGMENT(i);
		}
			ENDCG
		}
			}
				Fallback "Diffuse"
}