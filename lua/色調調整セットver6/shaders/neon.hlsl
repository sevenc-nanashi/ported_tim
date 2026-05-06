struct Constants {
  float a;
  float b;
  float c;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float apply_neon_curve(float value) {
  float byte_value = saturate(value) * 255.0;
  float curved = byte_value * (value * constants.a + constants.b) +
                 constants.c * 255.0 + 0.5;
  return floor(clamp(curved, 0.0, 255.0)) / 255.0;
}

float4 neon(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = srcTex.Load(int3(int2(floor(pos.xy)), 0));
  return float4(apply_neon_curve(rgba.r), apply_neon_curve(rgba.g),
                apply_neon_curve(rgba.b), rgba.a);
}
