struct Constants {
  float strength;
  float direction;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float emboss_weight(int direction, int index) {
  if (direction == 0) {
    const float weights[9] = {-2.0, -1.0, 0.0, -1.0, 0.0,
                              1.0,  0.0,  1.0, 2.0};
    return weights[index];
  }
  if (direction == 1) {
    const float weights[9] = {-1.0, -2.0, -1.0, 0.0, 0.0,
                              0.0,  1.0,  2.0,  1.0};
    return weights[index];
  }
  if (direction == 2) {
    const float weights[9] = {0.0, -1.0, -2.0, 1.0, 0.0,
                              -1.0, 2.0, 1.0,  0.0};
    return weights[index];
  }
  if (direction == 3) {
    const float weights[9] = {1.0, 0.0, -1.0, 2.0, 0.0,
                              -2.0, 1.0, 0.0,  -1.0};
    return weights[index];
  }
  if (direction == 4) {
    const float weights[9] = {2.0, 1.0, 0.0, 1.0, 0.0,
                              -1.0, 0.0, -1.0, -2.0};
    return weights[index];
  }
  if (direction == 5) {
    const float weights[9] = {1.0, 2.0, 1.0, 0.0, 0.0,
                              0.0, -1.0, -2.0, -1.0};
    return weights[index];
  }
  if (direction == 6) {
    const float weights[9] = {0.0, 1.0, 2.0, -1.0, 0.0,
                              1.0, -2.0, -1.0, 0.0};
    return weights[index];
  }
  const float weights[9] = {-1.0, 0.0, 1.0, -2.0, 0.0,
                            2.0,  -1.0, 0.0, 1.0};
  return weights[index];
}

float4 emboss(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  uint width, height;
  srcTex.GetDimensions(width, height);

  int2 pixel = int2(floor(pos.xy));
  float4 center = srcTex.Load(int3(pixel, 0));
  if (pixel.x <= 0 || pixel.y <= 0 || pixel.x >= (int)width - 1 ||
      pixel.y >= (int)height - 1) {
    return center;
  }

  int direction = ((uint)round(constants.direction) % 8 + 8) % 8;
  float strength = clamp(constants.strength, -10.0, 10.0);
  float3 conv = 0.0;
  int index = 0;
  [unroll]
  for (int oy = -1; oy <= 1; ++oy) {
    [unroll]
    for (int ox = -1; ox <= 1; ++ox) {
      conv += srcTex.Load(int3(pixel + int2(ox, oy), 0)).rgb *
              emboss_weight(direction, index);
      index += 1;
    }
  }

  return float4(center.rgb + conv * strength, center.a);
}
