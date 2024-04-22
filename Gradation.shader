Shader "Unlit/Gradation"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0


        _Color1("Color1", Color) = (1,1,1,1)
        _Color1Pos("Pos1", Range(0.0, 1.0)) = 0.0
        _Color2("Color2", Color) = (1,1,1,1)
        _Color2Pos("Pos2", Range(0.0, 1.0))  = 0.5
        _Color3("Color3", Color) = (1,1,1,1)
        _Color3Pos("Pos3", Range(0.0, 1.0)) = 1.0

        [HideInInspector]_Rot("Rot", Float) = 0.0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            const float PI = 3.141592;            

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            float3 _Color1;
            float _Color1Pos;
            float3 _Color2;
            float _Color2Pos;
            float3 _Color3;
            float _Color3Pos;
            float _Rot;

            // https://docs.unity3d.com/ja/Packages/com.unity.shadergraph@10.0/manual/Inverse-Lerp-Node.html
            float inverseLerp(float a, float b, float t)
            {
                return (t - a) / (b - a);
            }

            float2x2 rot(float a)
            {
                return float2x2(cos(a), sin(a), -sin(a), cos(a));
            }

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

                OUT.texcoord.xy = mul(OUT.texcoord.xy - .5, rot(_Rot)) + .5;


                OUT.color = v.color * _Color;
                return OUT;
            }

            float4 frag(v2f IN) : SV_Target
            {
                float4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
                float2 uv = IN.texcoord;

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                float t0 = saturate(inverseLerp(_Color2Pos, _Color3Pos, uv.x));
                float t1 = saturate(inverseLerp(_Color1Pos, _Color2Pos, uv.x));
                float3 color1 = lerp(_Color2, _Color3, t0);
                float3 color2 = lerp(_Color1, color1, t1);

                color.rgb = color2.rgb;
                return color;
            }
        ENDCG
        }
    }
}
