struct Constants {
  float shift;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float quantize(float value, uint shift) {
  if (shift >= 8) {
    return value;
  }

  uint channel = uint(round(value * 255.0));
  channel = (channel >> shift) << shift;
  return channel / 255.0;
}

float4 color_reduction(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float4 rgba = srcTex.Load(int3(int2(floor(pos.xy)), 0));
  uint shift = uint(round(constants.shift));
  return float4(quantize(rgba.r, shift), quantize(rgba.g, shift),
                quantize(rgba.b, shift), rgba.a);
}
