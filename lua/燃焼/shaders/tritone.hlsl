// NOTE: 元の計算結果となんか合わない...
// 元コード：
// https://github.com/sevenc-nanashi/ported_tim/blob/5d9e136adf3513d4f0bd98c05a866006f6937525/src/burning/unoptimized/tritone.rs

struct Constants {
  float color1R;
  float color1G;
  float color1B;
  float color2R;
  float color2G;
  float color2B;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D<float4> SrcTex : register(t0);
SamplerState SrcSmp : register(s0);

float unlerpClamped(float value, float minValue, float maxValue) {
  return clamp((value - minValue) / (maxValue - minValue), 0.0, 1.0);
}

float4 tritone(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = SrcTex.Sample(SrcSmp, uv);

  float3 color1 =
      float3(constants.color1R, constants.color1G, constants.color1B);
  float3 color2 =
      float3(constants.color2R, constants.color2G, constants.color2B);
  float3 colorMid = (color1 + color2) * 0.5;

  float luminance = dot(rgba.rgb, float3(0.298912, 0.58661, 0.114478));
  float t = unlerpClamped(luminance, 200.0 / 255.0, 1.0);
  float3 resultColor = lerp(color2, colorMid, t);

  return float4(resultColor * rgba.a, rgba.a);
}
