struct Constants {
  float col1R;
  float col1G;
  float col1B;
  float col2R;
  float col2G;
  float col2B;
  float change;
  float count;
  float scale;
  float useDistance;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float map_channel(float src, float target, float scale, float offset, bool useDistance) {
  float delta = src - target;
  float mapped = (useDistance ? abs(delta) : delta) * scale + offset;
  return clamp(mapped, 0.0, 255.0) / 255.0;
}

float4 standard_color(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  int2 pixel = int2(floor(pos.xy));
  float4 src = srcTex.Load(int3(pixel, 0));
  float3 src255 = src.rgb * 255.0;
  float t = constants.change;
  float invT = 1.0 - t;
  float3 target = float3(
      constants.col1R * invT + constants.col2R * t,
      constants.col1G * invT + constants.col2G * t,
      constants.col1B * invT + constants.col2B * t);
  float scale = constants.scale * 0.01;
  bool useDistance = constants.useDistance != 0.0;

  return float4(
      map_channel(src255.r, target.r, scale, constants.count, useDistance),
      map_channel(src255.g, target.g, scale, constants.count, useDistance),
      map_channel(src255.b, target.b, scale, constants.count, useDistance),
      src.a);
}
