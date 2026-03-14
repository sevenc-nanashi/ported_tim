struct Constants {
  float maxOffset;
  float radius;
  float centerX;
  float centerY;
  float seed;
  float basePosition;
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
                      uint randomHeight) {
  uint2 random_pixel1 =
      uint2(hash_coord(pixel.x, pixel.y, seed, 73u, 151u, 37u, randomWidth),
            hash_coord(pixel.x, pixel.y, seed, 199u, 101u, 89u, randomHeight));
  uint2 random_pixel2 = uint2(
      wrap_coord(
          hash_coord(pixel.x, pixel.y, seed, 41u, 61u, 17u, randomWidth) + 97u,
          randomWidth),
      wrap_coord(
          hash_coord(pixel.x, pixel.y, seed, 17u, 29u, 53u, randomHeight) +
              193u,
          randomHeight));
  return frac(randomTex.Load(int3((int2)random_pixel1, 0)).r +
              randomTex.Load(int3((int2)random_pixel2, 0)).r * 0.754877666);
}

float4 rad_rand_blur(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  uint width, height, randomWidth, randomHeight;
  srcTex.GetDimensions(width, height);
  randomTex.GetDimensions(randomWidth, randomHeight);

  float2 pixel = floor(pos.xy);
  float2 origin =
      float2(width * 0.5 + constants.centerX, height * 0.5 + constants.centerY);
  float2 offset = pixel - origin;
  float scale = (0.5 -
                 random_value_at((uint2)pixel, (uint)constants.seed,
                                 randomWidth, randomHeight) -
                 constants.basePosition * 0.5) *
                (constants.maxOffset / constants.radius);
  int2 sample_pixel = int2(round(pixel + offset * scale));
  sample_pixel =
      clamp(sample_pixel, int2(0, 0), int2((int)width - 1, (int)height - 1));

  return srcTex.Load(int3(sample_pixel, 0));
}
