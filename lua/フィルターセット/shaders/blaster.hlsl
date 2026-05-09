Texture2D srcTex : register(t0);

float trunc_zero(float value) {
  return value < 0.0 ? ceil(value) : floor(value);
}

float4 blaster(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  uint width, height;
  srcTex.GetDimensions(width, height);

  int2 pixel = int2(floor(pos.xy));
  bool hasInner = width >= 7 && height >= 7;
  bool inner = hasInner && pixel.x >= 3 && pixel.y >= 3 &&
               pixel.x < (int)width - 3 && pixel.y < (int)height - 3;

  float4 prepared = srcTex.Load(int3(pixel, 0));
  float gray = prepared.r;
  float alpha = prepared.b;
  if (inner) {
    alpha = 0.0;
    [unroll] for (int oy = -3; oy <= 3; ++oy) {
      for (int ox = -3; ox <= 3; ++ox) {
        alpha += srcTex.Load(int3(pixel + int2(ox, oy), 0)).g;
      }
    }
    alpha = trunc_zero(alpha * 255.0 / 49.0) / 255.0;
  }

  return float4(gray, gray, gray, 1.0) * alpha;
}
