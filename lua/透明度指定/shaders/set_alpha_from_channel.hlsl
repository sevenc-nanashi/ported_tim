struct Constants {
  float targetMethod;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState srcSmp : register(s0);

float3 to_straight_rgb(float4 rgba) {
  return rgba.a > 0.0 ? rgba.rgb / rgba.a : float3(0.0, 0.0, 0.0);
}

float get_target_alpha(float4 rgba, float3 straightRgb, float targetMethod) {
  if (targetMethod < 0.5) {
    return rgba.a;
  }
  if (targetMethod < 1.5) {
    return straightRgb.r;
  }
  if (targetMethod < 2.5) {
    return straightRgb.g;
  }
  if (targetMethod < 3.5) {
    return straightRgb.b;
  }
  return (straightRgb.r + straightRgb.g + straightRgb.b) / 3.0;
}

float4 set_alpha_from_channel(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float4 rgba = srcTex.Sample(srcSmp, uv);
  float3 straightRgb = to_straight_rgb(rgba);
  float alpha =
      saturate(get_target_alpha(rgba, straightRgb, constants.targetMethod));
  return float4(0.0, 0.0, 0.0, alpha);
}
