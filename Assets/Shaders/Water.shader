Shader "Custom/Water"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        [Normal] _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [Normal] _NormalMap ("Normal Map", 2D) = "bump" {}
        _Alpha ("Alpha", Range(0, 1)) = 1
        _Speed ("Wave Speed", Range(0.1, 80)) = 5
        _Frequency ("Wave Frequency", Range(0, 5)) = 2
        _Amplitude("Wave Amplitude", Range(-1, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        CGPROGRAM
        #pragma surface surf Lambert vertex:vert alpha:blend

        sampler2D _MainTex;
        sampler2D _NormalMap;
        float _Speed, _Frequency, _Amplitude, _Alpha;
        fixed4 _Color;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalMap;
        };

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            float time = _Time * _Speed;
            float waveValueA = sin(time + v.vertex.x * _Frequency) * _Amplitude;
            v.vertex.xyz = float3(v.vertex.x, v.vertex.y + waveValueA, v.vertex.z);
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Aplicando a cor base
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;

            // Aplicando o mapa de normal
            fixed3 normalTex = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
            o.Normal = normalTex;

            // Definindo transparência
            o.Alpha = _Alpha;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
