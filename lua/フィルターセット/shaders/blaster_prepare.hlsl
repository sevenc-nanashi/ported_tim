struct Constants {
  float direction;
  float edgeStrength;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float3 to_straight_rgb(float4 rgba) {
  return rgba.a > 0.0 ? rgba.rgb / rgba.a : 0.0;
}

float trunc_zero(float value) {
  return value < 0.0 ? ceil(value) : floor(value);
}

float lut(float value) { return clamp(value * 2.0 - 128.0, 0.0, 255.0); }

float4 straight_bgra_bytes(int2 pixel) {
  float4 rgba = srcTex.Load(int3(pixel, 0));
  float3 rgb = to_straight_rgb(rgba);
  return round(saturate(float4(rgb.b, rgb.g, rgb.r, rgba.a)) * 255.0);
}

uint packed_bgra(int2 pixel) {
  uint4 bgra = (uint4)straight_bgra_bytes(pixel);
  return bgra.x | (bgra.y << 8) | (bgra.z << 16) | (bgra.w << 24);
}

float blue_byte(int2 pixel) { return straight_bgra_bytes(pixel).x; }

float alpha_byte(int2 pixel) { return straight_bgra_bytes(pixel).w; }

float blaster_weight(int direction, int index) {
  if (direction == 0) {
    const float weights[8] = {2.0, 1.0, 0.0, 1.0, -1.0, 0.0, -1.0, -2.0};
    return weights[index];
  }
  if (direction == 1) {
    const float weights[8] = {1.0, 2.0, 1.0, 0.0, 0.0, -1.0, -2.0, -1.0};
    return weights[index];
  }
  if (direction == 2) {
    const float weights[8] = {0.0, 1.0, 2.0, -1.0, 1.0, -2.0, -1.0, 0.0};
    return weights[index];
  }
  if (direction == 3) {
    const float weights[8] = {-1.0, 0.0, 1.0, -2.0, 2.0, -1.0, 0.0, 1.0};
    return weights[index];
  }
  if (direction == 4) {
    const float weights[8] = {-2.0, -1.0, 0.0, -1.0, 1.0, 0.0, 1.0, 2.0};
    return weights[index];
  }
  if (direction == 5) {
    const float weights[8] = {-1.0, -2.0, -1.0, 0.0, 0.0, 1.0, 2.0, 1.0};
    return weights[index];
  }
  if (direction == 6) {
    const float weights[8] = {0.0, -1.0, -2.0, 1.0, -1.0, 2.0, 1.0, 0.0};
    return weights[index];
  }
  const float weights[8] = {1.0, 0.0, -1.0, 2.0, -2.0, 1.0, 0.0, -1.0};
  return weights[index];
}

uint add_weighted(uint value, uint source, float weight) {
  int w = (int)weight;
  if (w == -2) {
    return value - source * 2u;
  }
  if (w == -1) {
    return value - source;
  }
  if (w == 1) {
    return value + source;
  }
  if (w == 2) {
    return value + source * 2u;
  }
  return value;
}

float signed_i32_to_float(uint value) {
  return value >= 0x80000000u ? (float)value - 4294967296.0 : (float)value;
}

float edge_convolution(int2 pixel) {
  static const int2 offsets[8] = {
      int2(-1, -1), int2(0, -1), int2(1, -1), int2(-1, 0),
      int2(1, 0),   int2(-1, 1), int2(0, 1),  int2(1, 1),
  };

  int direction = ((uint)round(constants.direction) % 8 + 8) % 8;
  uint value = 0u;
  [unroll] for (int i = 0; i < 8; ++i) {
    value = add_weighted(value, packed_bgra(pixel + offsets[i]),
                         blaster_weight(direction, i));
  }
  return signed_i32_to_float(value);
}

float first_edge_map(int2 pixel, bool inner) {
  float edge = inner ? edge_convolution(pixel) : 0.0;
  float converted = trunc_zero(edge * constants.edgeStrength * -0.00001);
  float index = clamp(128.0 - converted, 0.0, 255.0);
  return lut(index);
}

float mapped_gray(int2 pixel, bool inner, float blue) {
  float edgeMap = first_edge_map(pixel, inner);
  float index = clamp(trunc_zero(edgeMap * blue / 255.0), 0.0, 255.0);
  return lut(index);
}

float adjusted_alpha(float blue, float alpha, float mapped) {
  if (blue == 255.0 && mapped == 128.0) {
    return 0.0;
  }
  return alpha;
}

float4 blaster_prepare(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  uint width, height;
  srcTex.GetDimensions(width, height);

  int2 pixel = int2(floor(pos.xy));
  bool hasInner = width >= 7 && height >= 7;
  bool inner = hasInner && pixel.x >= 3 && pixel.y >= 3 &&
               pixel.x < (int)width - 3 && pixel.y < (int)height - 3;
  float blue = blue_byte(pixel);
  float alpha = alpha_byte(pixel);
  float gray = mapped_gray(pixel, inner, blue);
  alpha = adjusted_alpha(blue, alpha, gray);

  return float4(gray / 255.0, alpha / 255.0, blue / 255.0, 1.0);
}
