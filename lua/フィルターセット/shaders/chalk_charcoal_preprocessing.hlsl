struct Constants {
  float charcoalApply;
  float chalkApply;
  float penPressure;
  float threshold;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float3 to_straight_rgb(float4 rgba) {
  return rgba.a > 0.0 ? rgba.rgb / rgba.a : 0.0;
}

float threshold_curve(float value, float threshold) {
  threshold = clamp(threshold, 0.0, 1.0);
  if (value < threshold) {
    return threshold > 0.0 ? value * 0.5 / threshold : 0.0;
  }
  return threshold < 1.0 ? 0.5 + (value - threshold) * 0.5 / (1.0 - threshold)
                         : 1.0;
}

float4 chalk_charcoal_preprocessing(float4 pos : SV_Position, float2 uv
                                    : TEXCOORD0) : SV_TARGET {
  int2 pixel = int2(floor(pos.xy));
  float4 rgba = srcTex.Load(int3(pixel, 0));
  float v = to_straight_rgb(rgba).b;

  v = threshold_curve(v, constants.threshold);

  float penScale = constants.penPressure + 0.5;
  float chalkExp = constants.chalkApply + 1.0;
  float charcoalExp = constants.charcoalApply + 1.0;

  float chalk = 1.0 - pow(max(1.0 - v, 0.0), chalkExp);
  chalk = saturate((chalk - 0.5) * penScale + 0.5);

  float charcoal = pow(max(chalk, 0.0), charcoalExp);
  charcoal = saturate((charcoal - 0.5) * penScale + 0.5);

  return float4(charcoal, charcoal, charcoal, 1.0) * rgba.a;
}
