struct Constants {
  float length;
  float r1;
  float g1;
  float b1;
  float r2;
  float g2;
  float b2;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float3 to_straight_rgb(float4 rgba) {
  return rgba.a > 0.0 ? rgba.rgb / rgba.a : 0.0;
}

float sample_gray(int2 pixel, int width, int height) {
  int2 p = clamp(pixel, int2(0, 0), int2(width - 1, height - 1));
  return to_straight_rgb(srcTex.Load(int3(p, 0))).b;
}

float round_away_from_zero(float value) {
  return value < 0.0 ? ceil(value - 0.5) : floor(value + 0.5);
}

float4 chalk_charcoal(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  uint width, height;
  srcTex.GetDimensions(width, height);

  int2 pixel = int2(floor(pos.xy));
  float4 rgba = srcTex.Load(int3(pixel, 0));

  float d = clamp(round_away_from_zero(constants.length), 1.0, 10.0) * 0.5;
  int p2 = (int)round_away_from_zero(1.0 - d);
  int p1 = (int)round_away_from_zero(d);

  float localMax = 127.0 / 255.0;
  float localMin = 128.0 / 255.0;
  int localC = -1 - p2;
  int local8 = p2 - 1;
  int count = p1 - p2 + 1;
  while (count > 0) {
    int y1 = local8 + 1 + pixel.y;
    int x1 = localC + pixel.x;
    [unroll]
    for (int i = 0; i < 3; ++i) {
      localMax =
          max(localMax, sample_gray(int2(x1 + i, y1), (int)width, (int)height));
    }

    int y2 = local8 + 1 + pixel.y;
    int x2 = local8 + pixel.x;
    [unroll]
    for (int j = 0; j < 3; ++j) {
      localMin =
          min(localMin, sample_gray(int2(x2 + j, y2), (int)width, (int)height));
    }

    localC -= 1;
    local8 += 1;
    count -= 1;
  }

  float v = localMin == 128.0 / 255.0 ? localMax : localMin;
  float3 shadow = float3(constants.r1, constants.g1, constants.b1);
  float3 highlight = float3(constants.r2, constants.g2, constants.b2);
  float3 color = lerp(shadow, highlight, v);
  return float4(color, 1.0) * rgba.a;
}
