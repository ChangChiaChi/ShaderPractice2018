Shader "TA-Shader/Test/UsePass"
{
	Properties{
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex("Main Tex", 2D) = "White"{}
		_BumpMap("Normal Map", 2D) = "bump"{}
		_BumpScale("Bump Scale", Float) = 1.0
		_SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
		_Specular("Specular", 2D) = "White"{}
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}
	SubShader
	{
		UsePass "TA-Shader/BlinnShading/DNS/BASE"
		//UsePass "ApcShader/DissolveEffect2/BASE"
	}
	Fallback "Unlit/Texture"
}
