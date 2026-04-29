struct Constants {
  float expR;
  float expG;
  float expB;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float gamma_map(float value, float exponent) {
  if (value >= 1.0) {
    return 1.0;
  }

  float mapped = floor(pow(max(value, 0.0), exponent) * 255.0);
  return clamp(mapped / 255.0, 0.0, 1.0);
}

float4 gamma_correction(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float4 rgba = srcTex.Load(int3(int2(floor(pos.xy)), 0));
  return float4(gamma_map(rgba.r, constants.expR),
                gamma_map(rgba.g, constants.expG),
                gamma_map(rgba.b, constants.expB), rgba.a);
}
