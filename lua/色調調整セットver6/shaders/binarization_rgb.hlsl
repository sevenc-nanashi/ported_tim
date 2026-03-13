struct Constants {
  float thresholdR;
  float thresholdG;
  float thresholdB;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState srcSmp : register(s0);

float4 color_binarization_rgb(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float4 rgba = srcTex.Sample(srcSmp, uv);
  float3 rgb = float3(rgba.r, rgba.g, rgba.b);
  float3 binarized = float3(
      rgb.r > constants.thresholdR ? 1.0 : 0.0,
      rgb.g > constants.thresholdG ? 1.0 : 0.0,
      rgb.b > constants.thresholdB ? 1.0 : 0.0);

  return float4(binarized, rgba.a);
}
