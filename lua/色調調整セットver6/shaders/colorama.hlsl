struct Constants {
  float fShift;
  float cycleCount;
  float maxColors;
  float col1R;
  float col1G;
  float col1B;
  float col2R;
  float col2G;
  float col2B;
  float col3R;
  float col3G;
  float col3B;
  float col4R;
  float col4G;
  float col4B;
  float col5R;
  float col5G;
  float col5B;
  float col6R;
  float col6G;
  float col6B;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float wrap_index(float value, float count) {
  return value - floor(value / count) * count;
}

float3 pick_color(float index) {
  if (index < 0.5) {
    return float3(constants.col1R, constants.col1G, constants.col1B);
  }
  if (index < 1.5) {
    return float3(constants.col2R, constants.col2G, constants.col2B);
  }
  if (index < 2.5) {
    return float3(constants.col3R, constants.col3G, constants.col3B);
  }
  if (index < 3.5) {
    return float3(constants.col4R, constants.col4G, constants.col4B);
  }
  if (index < 4.5) {
    return float3(constants.col5R, constants.col5G, constants.col5B);
  }
  return float3(constants.col6R, constants.col6G, constants.col6B);
}

float4 colorama(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  int2 pixel = int2(floor(pos.xy));
  float4 src = srcTex.Load(int3(pixel, 0));
  float3 src255 = src.rgb * 255.0;

  float luminance =
      src255.r * 0.298912 + src255.g * 0.58661 + src255.b * 0.114478;
  float gradientIndex = floor(luminance * 4.0);
  float maxColors = clamp(floor(constants.maxColors), 1.0, 6.0);
  float x = (gradientIndex / 1020.0 + constants.fShift) *
            (maxColors * constants.cycleCount);
  float base = floor(x);
  float frac = x - base;
  float colorIndex = floor(wrap_index(base, maxColors));
  float nextIndex = floor(wrap_index(colorIndex + 1.0, maxColors));

  float3 mapped =
      pick_color(colorIndex) * (1.0 - frac) + pick_color(nextIndex) * frac;

  return float4(floor(clamp(mapped, 0.0, 255.0)) / 255.0, 1.0) * src.a;
}
