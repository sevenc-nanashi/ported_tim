struct Constants {
  float r_count;
  float g_count;
  float b_count;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float quantize_channel(float value, float level_count) {
  uint levels = min(max(uint(round(level_count)), 2u), 256u);
  uint steps = levels - 1u;
  uint channel = uint(round(saturate(value) * 255.0));
  uint bucket = (channel * steps + 127u) / 255u;
  uint quantized = (bucket * 255u) / steps;
  return float(quantized) / 255.0;
}

float4 posterize(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = srcTex.Load(int3(int2(floor(pos.xy)), 0));
  return float4(quantize_channel(rgba.r, constants.r_count),
                quantize_channel(rgba.g, constants.g_count),
                quantize_channel(rgba.b, constants.b_count), rgba.a);
}
