struct Constants {
  float amount;
  float contrast;
  float method;
  float seed;
  float color1R;
  float color1G;
  float color1B;
  float color2R;
  float color2G;
  float color2B;
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
  uint2 random_pixel = uint2(
      hash_coord(pixel.x, pixel.y, seed + offset, 73u, 151u, 37u, randomWidth),
      hash_coord(pixel.x, pixel.y, seed + offset, 199u, 101u, 89u,
                 randomHeight));
  return randomTex.Load(int3((int2)random_pixel, 0)).r;
}

float3 adjust_contrast_255(float3 rgb255, float contrast_scale) {
  return saturate(((rgb255 - 128.0) * contrast_scale + 128.0) / 255.0);
}

float4 grainy(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  uint randomWidth, randomHeight;
  randomTex.GetDimensions(randomWidth, randomHeight);

  int2 pixel = int2(floor(pos.xy));
  uint2 upixel = (uint2)pixel;
  uint seed = (uint)max(round(constants.seed), 0.0);
  float4 rgba = srcTex.Load(int3(pixel, 0));
  float3 rgb255 = rgba.rgb * 255.0;
  float contrast_scale = constants.contrast * 0.01;
  float3 color1 =
      float3(constants.color1R, constants.color1G, constants.color1B);
  float3 color2 =
      float3(constants.color2R, constants.color2G, constants.color2B);
  uint method = (uint)round(constants.method);

  if (method == 1u) {
    float luminance =
        contrast_scale * (rgb255.g * 0.58661 + rgb255.r * 0.298912 +
                          rgb255.b * 0.114478 - 128.0) +
        128.0;
    luminance = clamp(luminance, 0.0, 255.0);
    float threshold_shift = (constants.amount - 50.0) * 5.1205;
    float noise =
        random_value_at(upixel, seed, randomWidth, randomHeight, 0u) * 256.0 +
        threshold_shift;
    return float4(noise <= luminance ? color1 : color2, rgba.a);
  }

  if (method == 2u) {
    float noise_scale = constants.amount * 5.12;
    float3 noise =
        float3(random_value_at(upixel, seed, randomWidth, randomHeight, 1u),
               random_value_at(upixel, seed, randomWidth, randomHeight, 2u),
               random_value_at(upixel, seed, randomWidth, randomHeight, 3u)) *
            2.0 -
        1.0;
    float3 adjusted = (rgb255 - 128.0) * contrast_scale + 128.0;
    return float4(saturate((adjusted + noise * noise_scale) / 255.0), rgba.a);
  }

  float prob =
      random_value_at(upixel, seed, randomWidth, randomHeight, 4u) * 100.0;
  float3 src_or_color = prob < constants.amount ? color1 : rgba.rgb;
  return float4(adjust_contrast_255(src_or_color * 255.0, contrast_scale),
                rgba.a);
}
