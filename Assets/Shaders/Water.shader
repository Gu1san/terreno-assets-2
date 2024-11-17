Shader "Custom/Water"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [Normal] _NormalMap ("Normal Map", 2D) = "bump" {}
        _WaveTex ("Wave Texture", 2D) = "white" {}
        _Alpha ("Alpha", Range(0, 1)) = 1
        _Speed ("Wave Speed", Range(0.1, 80)) = 5
        _Frequency ("Wave Frequency", Range(0, 5)) = 2
        _Amplitude ("Wave Amplitude", Range(-1, 1)) = 1
        _Intensity ("Intensity", Range(0, 50)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        GrabPass { "_GrabTexture" }

        Pass
        {
            Tags { "Queue"="Geometry" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _WaveTex;
            float _Speed, _Frequency, _Amplitude, _Alpha;
            fixed4 _Color;

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float waveValue : TEXCOORD1; // Armazena o valor da onda para o fragment shader
            };

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v) {
                v2f o;

                // Calcula o deslocamento baseado na textura e no tempo
                float time = _Time.y * _Speed;
                float waveValue = tex2Dlod(_WaveTex, float4(v.uv, 0, 0)).r; // Amostra o canal R
                float wave = sin(time + v.vertex.x * _Frequency) * waveValue * _Amplitude;

                // Move os vértices com base na textura
                v.vertex.y += wave;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                fixed4 c = tex2D(_MainTex, i.uv) * _Color;
                c.a = _Alpha;
                return c;
            }
            ENDCG
        }
        Pass
        {
            Blend DstColor SrcAlpha
            Tags { "Queue"="Transparent" }
            CGPROGRAM
            #pragma vertex vertGrab
            #pragma fragment fragGrab
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _GrabTexture;
            float4 _MainTex_ST;
            half _Intensity;

            struct v2f {
                float4 pos : SV_POSITION;
                float4 uvGrab : TEXCOORD0;
                float2 uvMain : TEXCOORD1;
            };

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vertGrab(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uvGrab = ComputeGrabScreenPos(o.pos);
                o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 fragGrab(v2f i) : SV_Target {
                // Ondulação no GrabPass
                i.uvGrab.x += sin((_Time.y + i.uvGrab.y) * _Intensity) / 80;
                fixed4 grabColor = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvGrab));
                return grabColor;
            }

            
            ENDCG
        }
    }
    FallBack "Diffuse"
}
