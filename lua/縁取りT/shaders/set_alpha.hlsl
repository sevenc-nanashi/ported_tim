struct Constants {};

cbuffer constants : register(b0) { Constants constants; }
Texture2D<float4> StraightTex : register(t0);
Texture2D<float4> PmaTex : register(t1);
SamplerState SrcSmp : register(s0);

float4 set_alpha(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 straight = StraightTex.Sample(SrcSmp, uv);
  float4 pma = PmaTex.Sample(SrcSmp, uv);

  return float4(straight.rgb * pma.a, pma.a);
}
