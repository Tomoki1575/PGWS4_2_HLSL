Shader "Unlit/NewUnlitShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            /* ↑ここまでがShaderLab */
            /* ↓ここからがHLSL */
            CGPROGRAM           
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            // メインライトの向きを参照
            float4 _MainLightPosition;

            // 頂点シェーダ（位置と材料を準備）
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);       //  法線をワールド基準に変換
                // MEMO : 
                // v.vertex は「位置」、v.normal は「面がどっちを向いているか（法線）」。光の当たり方を決めるのは向きなので、法線を使う。
                // UnityObjectToWorldNormalとは、ローカル座標基準の向きをワールド座標基準の向きに直すもの。ライトの向きはワールド座標基準であるため、基準をそろえる。
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            // フラグメントシェーダー（実際に色を適応）
            fixed4 frag (v2f i) : SV_Target
            {
                // 一旦影を表現する
                // このtの値がそのまま影の割合になる
                float t = dot(normalize(i.normal),_MainLightPosition.xyz) * 0.5 + 0.5;

                t = floor(t * 7) / 7;       // 7段階にする

                // fixed4(0.1, 0.1, 0.3, 1) → 暗い青
                // fixed4(1, 0.9, 0.7, 1) → 明るいクリーム色
                // ↑この二つをtの割合で混ぜる（影の部分ほど、暗い青を多く混ぜる）
                fixed4 col = lerp(fixed4(0.1, 0.1, 0.3, 1), fixed4(1, 0.9, 0.7, 1), t);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG           // ここまでがHLSL
        }
    }
}
