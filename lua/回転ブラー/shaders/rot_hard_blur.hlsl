static const float PI = 3.14159265358979323846;

struct Constants {
  float blurAmountDeg;
  float radius;
  float centerX;
  float centerY;
  float count;
  float amplitudeBase;
  float roundness;
  float basePosition;
  float seed;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

int clamp_coord(int value, uint limit) {
  return clamp(value, 0, (int)limit - 1);
}

float4 load_clamped(int2 pixel, uint width, uint height) {
  int2 clamped =
      int2(clamp_coord(pixel.x, width), clamp_coord(pixel.y, height));
  return srcTex.Load(int3(clamped, 0));
}

float4 sample_bilinear_clamped(float2 samplePixel, uint width, uint height) {
  if (width == 0 || height == 0) {
    return float4(0.0, 0.0, 0.0, 0.0);
  }

  float2 clamped = clamp(samplePixel, float2(0.0, 0.0),
                         float2((float)width - 1.0, (float)height - 1.0));
  int2 base = int2(floor(clamped));
  int x0 = base.x;
  int y0 = base.y;
  int x1 = min(x0 + 1, (int)width - 1);
  int y1 = min(y0 + 1, (int)height - 1);
  float2 frac = clamped - base;
  float4 top =
      lerp(srcTex.Load(int3(x0, y0, 0)), srcTex.Load(int3(x1, y0, 0)), frac.x);
  float4 bottom =
      lerp(srcTex.Load(int3(x0, y1, 0)), srcTex.Load(int3(x1, y1, 0)), frac.x);
  return lerp(top, bottom, frac.y);
}

float shaped_fraction(float frac, float roundness) {
  float clampedFrac = clamp(frac, 0.0, 1.0);
  float clampedRoundness = clamp(roundness, -1.0, 1.0);
  if (clampedRoundness == 0.0) {
    return clampedFrac;
  }

  float direction = clampedFrac <= 0.5 ? -1.0 : 1.0;
  float mirrored = abs(clampedFrac * 2.0 - 1.0);
  float base = 1.0 - abs(clampedRoundness);
  float shaped;
  if (base <= mirrored) {
    float denom = 1.0 - base * base;
    shaped = denom <= 0.000001 ? 1.0 : 1.0 - pow(mirrored - 1.0, 2.0) / denom;
  } else {
    shaped = (mirrored * 2.0) / (base + 1.0);
  }

  float result = clampedRoundness <= 0.0
                     ? (direction * (mirrored * 2.0 - shaped) + 1.0) * 0.5
                     : (direction * shaped + 1.0) * 0.5;
  return clamp(result, 0.0, 1.0);
}

int c_rand(int seed) { return seed * 214013 + 2531011; }

float segment_random(float seedValue, int index) {
  int seed = (int)round(seedValue);
  int seedBase = seed * seed * 12;
  int cubic = index * index * index;
  int coeff = index < 1 ? -1135 : 32541;
  int hold = seedBase + cubic * coeff;
  int randValue = c_rand(hold);
  float randBucket = (float)((randValue >> 16) & 32767);
  return frac(randBucket * 0.001);
}

float hard_pattern(float seed, float phase, float amplitudeBase,
                   float roundness, float basePosition) {
  int seg0 = (int)floor(phase);
  int seg1 = seg0 + 1;
  float frac = phase - seg0;
  float clampedAmplitudeBase = clamp(amplitudeBase, 0.0, 1.0);
  float amp0 = clampedAmplitudeBase +
               (1.0 - clampedAmplitudeBase) * segment_random(seed, seg0);
  float amp1 = clampedAmplitudeBase +
               (1.0 - clampedAmplitudeBase) * segment_random(seed, seg1);
  float negAmp0 =
      1.0 - (1.0 - clampedAmplitudeBase) * segment_random(seed, seg0);
  float negAmp1 =
      1.0 - (1.0 - clampedAmplitudeBase) * segment_random(seed, seg1);
  float clampedBasePosition = clamp(basePosition, -1.0, 1.0);
  float negScale = 0.5 * (1.0 - clampedBasePosition);
  float posScale = 0.5 * (1.0 + clampedBasePosition);
  float startValue;
  float endValue;
  if ((seg0 & 1) == 0) {
    startValue = -negAmp0 * negScale;
    endValue = amp1 * posScale;
  } else {
    startValue = amp0 * posScale;
    endValue = -negAmp1 * negScale;
  }
  return lerp(startValue, endValue, shaped_fraction(frac, roundness));
}

float4 rot_hard_blur(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  uint width, height;
  srcTex.GetDimensions(width, height);

  float2 pixel = floor(pos.xy);
  float2 origin =
      float2(width * 0.5 + constants.centerX, height * 0.5 + constants.centerY);
  float2 offset = pixel - origin;
  int sampleCount = max((int)round(constants.count), 1);
  float safeRadius = max(abs(constants.radius), 1.0);
  float phase = length(offset) * sampleCount / safeRadius;
  float angle = constants.blurAmountDeg * PI / 180.0 *
                hard_pattern(constants.seed, phase, constants.amplitudeBase,
                             constants.roundness, constants.basePosition);
  float sinTheta = sin(angle);
  float cosTheta = cos(angle);
  float2 samplePixel =
      float2(origin.x + offset.x * cosTheta + offset.y * sinTheta,
             origin.y + offset.y * cosTheta - offset.x * sinTheta);

  return sample_bilinear_clamped(samplePixel, width, height);
}
