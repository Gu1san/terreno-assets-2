Shader "Custom/Submerse"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Intensity ("Intensity", Range(0, 50)) = 0
    }
    SubShader
    {
        GrabPass { "_GrabTexture" }
        Pass{
            Tags { "Queue"="Transparent" }
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex, _GrabTexture;
            half _Intensity;
            float4 _MainTex_ST;

            struct v2f {
                float4 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = ComputeGrabScreenPos(o.vertex);
                o.uv2 = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                i.uv2.x += _Time.x;
                half4 tex = tex2D(_MainTex, i.uv2);
                i.uv.x += sin((_Time.x + i.uv.y)* tex.r * _Intensity)/80;
                fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uv));
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
