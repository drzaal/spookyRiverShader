Shader "Poikolos/aminatedtiled"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
        _Speed ("Frame Speed", Float) = 0.4
        _OffsetTimeNudge ("Offsets Frame Time Difference", Float) = 0.4
        _Bamplitude ("BAMplitude", Float) = 0
        _XSpeed ("X Speed", Float) = 0
        _YSpeed ("Y Speed", Float) = 0
        _XFrames ("X Frames", Int) = 1
        _YFrames ("Y Frames", Int) = 1
        _XOverlap ("X Overlap", Float) = 0
        _YOverlap ("Y Overlap", Float) = 0
	}
	SubShader
	{
		// No culling or depth
	    //Tags { "RenderType"="Opaque" }Cull Off
		Lighting Off
		ZWrite Off

		Tags
		{
			"RenderType" = "Opaque"
		}

        CGPROGRAM
        //#pragma vertex vert
        //#pragma fragment frag
        #pragma surface surf Lambert

        #define M_PI 3.1415926535897932384626433832795
        
        #include "UnityCG.cginc"
        
        uniform sampler2D _MainTex;
        uniform float4 _Color;
        uniform fixed _ColorIntensity;
        uniform fixed _Threshold;
        uniform fixed _Potency;
        uniform fixed _Squash;
        uniform fixed _HardSquash;
        uniform fixed _Speed;
        uniform float _OffsetTimeNudge;
        uniform float _Bamplitude;
        uniform float _XSpeed;
        uniform float _YSpeed;
        uniform int _XFrames;
        uniform int _YFrames;
        uniform float _XOverlap;
        uniform float _YOverlap;

        struct Vertex {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
            fixed4 color : COLOR;
        };

        struct v2f {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            fixed4 color : COLOR;
            //float3 viewDir : TEXCOORD2;
            //UNITY_FOG_COORDS(3)
        };
        struct Input {
            float2 uv_MainTex;
        };

        fixed4 mags(fixed4 i)
        {
            return max(sign(i), 0.0) - sign(i) * _Threshold;
            //return i;
        }
        
        v2f vert(Vertex v)
        {
            v2f o;
            
            //o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.uv;
            o.color = v.color;
            //o.uv2 = v.uv2;
            
            return o;
        }

        fixed2 frame2uv (float frame)
        { 
            // DONT try to cast back and forth from int, it causes weird problems

            fixed2 frameOffset = floor(fixed2(
                fmod(frame, _XFrames),
                -fmod(floor(frame / _XFrames), _YFrames)
            ))
            / fixed2(_XFrames, _YFrames);

            return frameOffset;
        }

        void surf (Input i, inout SurfaceOutput o)
        {
            float2 texuv = i.uv_MainTex + _Bamplitude * sin(M_PI * _Time.w * fixed2(_XSpeed, _YSpeed));
            fixed4 col;

            float frameTime = _Time.w * _Speed;
            float nudge = _OffsetTimeNudge;

            float2 overlayOffset = float2(
                _XOverlap,
                _YOverlap
            );

            fixed2 first = frame2uv(frameTime);
            fixed2 directuv = frac(texuv) / float2(_XFrames, _YFrames);
            fixed4 col1 = tex2D(_MainTex, first + directuv);
            col1 = col1 * step(0.1, col1);

            fixed2 second = frame2uv(frameTime + nudge);
            fixed2 offsetuv = frac(texuv + overlayOffset) / float2(_XFrames, _YFrames);
            fixed4 col2 = tex2D(_MainTex, second + offsetuv);
            
            col2 = col2 * step(0.1, col2);

            col = (1 - any(col2.rgb)) * col1 + col2;

            //col = col1 + col2;

            col *= _Color;
            //col.rgb = fixed3(first.x, first.y, 0.01 * int(frameTime));

            o.Albedo = col.rgb;
            o.Alpha = col.a;
        }
        ENDCG
	}
}
