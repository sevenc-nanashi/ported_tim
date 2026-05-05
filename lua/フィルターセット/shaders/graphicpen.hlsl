struct Constants {
  float threshold;
  float whiteAdj;
  float blackAdj;
  float lineLength;
  float scanRadius;
  float stepX;
  float stepY;
  float seed;
  float shadowR;
  float shadowG;
  float shadowB;
  float highlightR;
  float highlightG;
  float highlightB;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
Texture2D randomTex : register(t1);

uint wrap_coord(uint value, uint modulus) {
  return value - (value / modulus) * modulus;
}

uint hash_coord(uint x, uint y, uint seed, uint a, uint b, uint c,
                uint modulus) {
  return wrap_coord(x * a + y * b + seed * c, modulus);
}

float random_value_at(uint2 pixel, uint seed, uint randomWidth,
                      uint randomHeight, uint offset) {
  uint2 random_pixel1 = uint2(
      hash_coord(pixel.x, pixel.y, seed + offset, 73u, 151u, 37u, randomWidth),
      hash_coord(pixel.x, pixel.y, seed + offset, 199u, 101u, 89u, randomHeight));
  uint2 random_pixel2 = uint2(
      wrap_coord(hash_coord(pixel.x, pixel.y, seed + offset, 41u, 61u, 17u,
                            randomWidth) +
                     97u,
                 randomWidth),
      wrap_coord(hash_coord(pixel.x, pixel.y, seed + offset, 17u, 29u, 53u,
                            randomHeight) +
                     193u,
                 randomHeight));
  return frac(randomTex.Load(int3((int2)random_pixel1, 0)).r +
              randomTex.Load(int3((int2)random_pixel2, 0)).r * 0.754877666);
}

float source_gray_at(int2 pixel) { return srcTex.Load(int3(pixel, 0)).r; }

float lut_value(float gray255, float threshold255) {
  float threshold_mode = round(threshold255);
  if (gray255 <= threshold_mode) {
    float low_den = threshold255 + 1.0;
    return 1.0 - ((gray255 + 1.0) / max(low_den, 1.0));
  }

  float high_den = (255.0 - threshold255) + 1.0;
  return (gray255 - threshold255) / max(high_den, 1.0);
}

float4 graphicpen(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  uint width, height, randomWidth, randomHeight;
  srcTex.GetDimensions(width, height);
  randomTex.GetDimensions(randomWidth, randomHeight);

  int2 pixel = int2(floor(pos.xy));
  float current_gray = source_gray_at(pixel);
  float final_gray = current_gray;
  int best_index = -1;

  float threshold255 = constants.threshold * 255.0;
  int inner_margin = (int)round(constants.lineLength);
  int max_offset = (int)round(constants.scanRadius);
  int2 step = int2((int)round(constants.stepX), (int)round(constants.stepY));
  uint seed = (uint)max(constants.seed, 0.0);

  [loop]
  for (int t = -max_offset; t <= max_offset; ++t) {
    int2 source_pixel = pixel - step * t;
    if (source_pixel.x < inner_margin || source_pixel.x >= (int)width - inner_margin ||
        source_pixel.y < inner_margin || source_pixel.y >= (int)height - inner_margin) {
      continue;
    }

    int source_index = source_pixel.y * (int)width + source_pixel.x;
    float source_gray = source_gray_at(source_pixel);
    float source_gray255 = round(source_gray * 255.0);
    bool dark_source = source_gray255 <= round(threshold255);
    float candidate_gray = dark_source ? 0.0 : 1.0;

    float lut = lut_value(source_gray255, threshold255);
    float adjust = dark_source ? constants.whiteAdj : constants.blackAdj;
    float r0 =
        random_value_at((uint2)source_pixel, seed, randomWidth, randomHeight, 0u);
    if (lut + adjust < r0) {
      float r1 =
          random_value_at((uint2)source_pixel, seed, randomWidth, randomHeight, 1u);
      float d = constants.lineLength * r1 + 1.0;
      int start = (int)round(d * -0.5);
      int end = (int)round(d * 0.5);
      if (end > start && t >= start && t < end) {
        candidate_gray = dark_source ? 1.0 : 0.0;
      }
    }

    if (source_index >= best_index) {
      best_index = source_index;
      final_gray = candidate_gray;
    }
  }

  float4 rgba = srcTex.Load(int3(pixel, 0));
  float3 shadow = float3(constants.shadowR, constants.shadowG, constants.shadowB);
  float3 highlight =
      float3(constants.highlightR, constants.highlightG, constants.highlightB);
  return float4(lerp(shadow, highlight, final_gray), rgba.a);
}
