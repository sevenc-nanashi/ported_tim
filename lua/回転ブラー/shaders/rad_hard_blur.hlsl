static const float PI = 3.14159265358979323846;

struct Constants {
  float blurAmount;
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

int c_rand(int seed) {
  return seed * 214013 + 2531011;
}

int positive_mod(int value, int modulus) {
  float quotient = floor((float)value / (float)modulus);
  int result = value - (int)(quotient * modulus);
  return result < 0 ? result + modulus : result;
}

int wrap_segment(int index, int period) {
  return period > 0 ? positive_mod(index, period) : index;
}

float segment_random(float seedValue, int index, int period) {
  int wrappedIndex = wrap_segment(index, period);
  int seed = (int)round(seedValue);
  int seedBase = seed * seed * 12;
  int cubic = wrappedIndex * wrappedIndex * wrappedIndex;
  int coeff = wrappedIndex < 1 ? -1135 : 32541;
  int hold = seedBase + cubic * coeff;
  int randValue = c_rand(hold);
  float randBucket = (float)((randValue >> 16) & 32767);
  return frac(randBucket * 0.001);
}

float hard_pattern(float seed, float phase, int period, float amplitudeBase, float roundness, float basePosition) {
  int seg0 = (int)floor(phase);
  int seg1 = seg0 + 1;
  float frac = phase - seg0;
  float clampedAmplitudeBase = clamp(amplitudeBase, 0.0, 1.0);
  float amp0 = clampedAmplitudeBase + (1.0 - clampedAmplitudeBase) * segment_random(seed, seg0, period);
  float amp1 = clampedAmplitudeBase + (1.0 - clampedAmplitudeBase) * segment_random(seed, seg1, period);
  float negAmp0 = 1.0 - (1.0 - clampedAmplitudeBase) * segment_random(seed, seg0, period);
  float negAmp1 = 1.0 - (1.0 - clampedAmplitudeBase) * segment_random(seed, seg1, period);
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

float4 sample_nearest_transparent(float2 samplePixel, uint width, uint height) {
  int2 nearest = int2(trunc(samplePixel + 0.5));
  if (nearest.x < 0 || nearest.y < 0 || nearest.x >= (int)width || nearest.y >= (int)height) {
    return float4(0.0, 0.0, 0.0, 0.0);
  }
  return srcTex.Load(int3(nearest, 0));
}

float4 rad_hard_blur(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  uint width, height;
  srcTex.GetDimensions(width, height);

  float2 pixel = floor(pos.xy);
  float2 origin = float2(width * 0.5 + constants.centerX, height * 0.5 + constants.centerY);
  float2 offset = pixel - origin;
  int sampleCount = max((int)round(constants.count), 1);
  int period = sampleCount * 2;
  float phase = (atan2(offset.y, offset.x) / PI + 1.0) * sampleCount;
  float scale = 1.0 - constants.blurAmount *
      hard_pattern(
          constants.seed,
          phase,
          period,
          constants.amplitudeBase,
          constants.roundness,
          constants.basePosition);
  float2 samplePixel = origin + offset * scale;

  return sample_nearest_transparent(samplePixel, width, height);
}
