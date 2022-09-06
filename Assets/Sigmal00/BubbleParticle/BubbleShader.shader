Shader "Sigmal00/BubbleShader"
{
	Properties
	{
		[Header(General Settings)]
		[Space(8)]
		_BaseColor("Base Color", Color) = (0.5235849,0.8990369,1,0)
        _BaseTex ("Base Map", 2D) = "white" {}
        _MaskTex ("Mask", 2D) = "white" {}
		[Toggle]_InverseMask("Inverse Mask", Int) = 0
		_Smoothness("Smoothness", Range(0, 1)) = 1
		_Metallic("Metallic", Range(0, 1)) = 0

		[Header(Opacity Settings)]
		[Space(8)]
		_FresnelExp("Fresnel Exp", Range(0, 10)) = 5
		_MinOpacity("Min Opacity", Range(0, 1)) = 0
		_MaxOpacity("Max Opacity", Range(0, 1)) = 1

		[Header(Structural Color Settings)]
		[Space(8)]
		_StructuralColorStrength("Strength", Float) = 1
		_EmissiveStrength("Emissive Strength", Float) = 1
		_Freq("Frequency", Float) = 1

		[Header(Noise Settings)]
		[Space(8)]
		_NoiseStrength("Noise Strength", Float) = 1
		_NoiseFreq("Noise Frequency", Float) = 1
		_NoiseScroll("Noise Scroll Speed", Float) = 1

		[Header(Wave Noise Settings)]
		[Space(8)]
		_WaveNoiseStrength("Wave Strength", Float) = 1
		_WaveNoiseFreq("Wave Frequency", Float) = 1
		_WaveNoiseScroll("Wave Scroll Speed", Float) = 0
		_WaveThresholdSize("Wave Threshold Size", Float) = 0.02
		_WaveThresholdSizeGradient("Wave Threshold Size Gradient", Float) = 0.1

		[Header(General Settings)]
		[Space(8)]
        _TransformMap ("Transform Map", 2D) = "black" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite Off
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard alpha:fade addshadow keepalpha exclude_path:deferred vertex:vert
        #pragma multi_compile_instancing
        #pragma instancing_options procedural:vertInstancingSetup
        #pragma exclude_renderers gles
        #include "UnityStandardParticleInstancing.cginc"
		struct Input
		{
            float2 uv_BaseTex;
			float3 viewDir;
			float3 worldNormal;
			float3 worldPos;
            fixed4 vertexColor;
		};

		uniform float4 _BaseColor;
		uniform sampler2D _BaseTex, _MaskTex;
		int _InverseMask;
		uniform float _Metallic, _Smoothness;
		uniform float _MinOpacity, _MaxOpacity, _FresnelExp;

		uniform float _Freq, _StructuralColorStrength;
		uniform float _EmissiveStrength;

		uniform float _WaveNoiseStrength, _WaveNoiseFreq, _WaveNoiseScroll, _WaveThresholdSize, _WaveThresholdSizeGradient;

		uniform float _NoiseStrength, _NoiseFreq, _NoiseScroll;

		uniform sampler2D _TransformMap;

		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}

		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}

		float fbm(float3 p)
		{
			float value = 0.0f;
			float amplitude = 1.0f;
			[unroll]
			for(int i = 0; i < 2; ++i)
			{
				value += amplitude*snoise(p);
				amplitude *= 0.5f;
				p *= 2.0f;
			}
			return value;;
		}

		float domainWarp(float3 p)
		{
			float3 offset = float3(0.125f, 1.0125f, 12.0f);
			float f = fbm(p + fbm(p + offset));

			return f*f*f + 0.6f*f*f + 0.5f*f;
		}

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

			// ある程度大きくないとたわまないように
			float3 objScale = float3(length(unity_ObjectToWorld[0].xyz), length(unity_ObjectToWorld[1].xyz), length(unity_ObjectToWorld[2].xyz));
			float3 waveStartFactor = saturate((objScale - _WaveThresholdSize.xxx)/max(_WaveThresholdSizeGradient, 0.0001f));

			// ノイズでそれっぽくたわませる
			float3 p = v.vertex.xyz+5.0f*mul(unity_ObjectToWorld, float4(0,0,0,1));
			p = _WaveNoiseFreq*(p) + _WaveNoiseScroll*float3(0, _Time.x, 0);
			float amount = _WaveNoiseStrength*snoise(p);
			v.vertex.xyz += amount*v.normal*waveStartFactor;
            vertInstancingColor(o.vertexColor);
        }

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float alphaMask = tex2D (_MaskTex, i.uv_BaseTex).r;
			if(_InverseMask == 1) alphaMask = saturate(1.0f - alphaMask);

			float3 objPos = mul(unity_WorldToObject, float4(i.worldPos, 1.0f));
			objPos += 0.1f;

			if(alphaMask <= 0.0f) discard;

			float4 baseColor = tex2D (_BaseTex, i.uv_BaseTex)*_BaseColor;
			o.Albedo = baseColor.rgb;
			#ifdef UNITY_PARTICLE_INSTANCING_ENABLED
			o.Albedo *= i.vertexColor.rgb;
			#endif

			// 構造色
			float noiseValue = _NoiseStrength * domainWarp(_NoiseFreq * objPos + float3(0, _NoiseScroll*_Time.x, 0));

			float3 hsv = float3(0.5f, 0.95f, 1.0f);
			float vdn = abs(dot( i.viewDir , i.worldNormal ));

			// 色相をずらす
			hsv.x += _Freq*(vdn + noiseValue);

			float3 structuralColor = _StructuralColorStrength*HSVToRGB(hsv);
			o.Albedo += structuralColor;
			o.Emission = _EmissiveStrength*structuralColor;

			// 質感
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;

			// 透明度
			float fresnel = pow( 1.0f - vdn, _FresnelExp);
			o.Alpha = alphaMask*baseColor.a * lerp( _MinOpacity , _MaxOpacity , fresnel);
			#ifdef UNITY_PARTICLE_INSTANCING_ENABLED
			o.Alpha *= i.vertexColor.a;
			#endif

		}

		ENDCG
	}
	Fallback "Diffuse"
}