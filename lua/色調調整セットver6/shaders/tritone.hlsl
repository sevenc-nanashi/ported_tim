struct Constants {
  float color1R;
  float color1G;
  float color1B;
  float color2R;
  float color2G;
  float color2B;
  float color3R;
  float color3G;
  float color3B;
  float threshold1;
  float threshold2;
  float threshold3;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState srcSmp : register(s0);

float unlerpClamped(float value, float min, float max) {
  if (max - min == 0.0) {
    return 0.0; // Avoid division by zero
  }
  return clamp((value - min) / (max - min), 0.0, 1.0);
}
float quantize(float value, float step) {
  if (step == 0.0) {
    return value; // Avoid division by zero
  }
  return round(value * step) / step;
}

float4 tritone(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = srcTex.Sample(srcSmp, uv);
  float4 straightRgba =
      rgba.a > 0.0 ? rgba / rgba.a : float4(0.0, 0.0, 0.0, 0.0);

  float3 luma = float3(0.298912, 0.58661, 0.114478);
  float metric = dot(straightRgba.rgb, luma);

  float3 col1 = float3(constants.color1R, constants.color1G, constants.color1B);
  float3 col2 = float3(constants.color2R, constants.color2G, constants.color2B);
  float3 col3 = float3(constants.color3R, constants.color3G, constants.color3B);

  float3 color = lerp(
      lerp(col3, col2,
           unlerpClamped(metric, constants.threshold3, constants.threshold2)),
      col1, unlerpClamped(metric, constants.threshold2, constants.threshold1));

  return float4(color, 1.0) * rgba.a;
}
