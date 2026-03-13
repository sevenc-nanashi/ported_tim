struct Constants {
  float threshold1;
  float threshold2;
  float weightR;
  float weightG;
  float weightB;
  float inScale;
  float outScale;
  float colR;
  float colG;
  float colB;
  float invertRange;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState srcSmp : register(s0);

float is_within_range(float value, float threshold_1, float threshold_2) {
  return step(threshold_1, value) * step(value, threshold_2);
}

float4 threshold(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = srcTex.Sample(srcSmp, uv);

  float metric = (rgba.r * constants.weightR + rgba.g * constants.weightG +
                  rgba.b * constants.weightB);

  float within_range =
      is_within_range(metric, constants.threshold1, constants.threshold2);
  within_range = abs(constants.invertRange - within_range);

  float4 colHit = float4(
      constants.colR * constants.inScale, constants.colG * constants.inScale,
      constants.colB * constants.inScale, rgba.a * constants.inScale);
  float4 colMiss =
      float4(rgba.rgb * constants.outScale, rgba.a * constants.outScale);

  return lerp(colMiss, colHit, within_range);
}
