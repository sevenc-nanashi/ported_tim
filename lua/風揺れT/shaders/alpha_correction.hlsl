struct Constants {};

cbuffer constants : register(b0) { Constants constants; }
Texture2D<float4> ColorTex : register(t0);
Texture2D<float4> AlphaTex : register(t1);
SamplerState SrcSmp : register(s0);

float3 to_straight_rgb(float4 pma) {
  return pma.a > 0.0 ? pma.rgb / pma.a : float3(0.0, 0.0, 0.0);
}

float4 extract_straight_color(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float4 pma = ColorTex.Sample(SrcSmp, uv);
  return float4(to_straight_rgb(pma), 1.0);
}

float4 extract_alpha(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float alpha = ColorTex.Sample(SrcSmp, uv).a;
  return float4(0.0, 0.0, 0.0, alpha);
}

float4 combine_color_alpha(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float3 straight_rgb = ColorTex.Sample(SrcSmp, uv).rgb;
  float alpha = AlphaTex.Sample(SrcSmp, uv).a;
  return float4(straight_rgb * alpha, alpha);
}
