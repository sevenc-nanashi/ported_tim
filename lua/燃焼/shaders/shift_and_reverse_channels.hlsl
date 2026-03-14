
struct Constants {};

cbuffer constants : register(b0) { Constants constants; }
Texture2D<float4> SrcTex : register(t0);
SamplerState SrcSmp : register(s0);

float4 shift_and_reverse_channels(float4 pos : SV_Position,
                                  float2 uv : TEXCOORD0)
    : SV_TARGET {
  float4 rgba = SrcTex.Sample(SrcSmp, uv);

  return float4(0.0, 0.0, 0.0, 1.0 - clamp(rgba.r, 0.0, 1.0));
}
