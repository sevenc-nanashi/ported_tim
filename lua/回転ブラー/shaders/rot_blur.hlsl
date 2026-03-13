struct Constants {
  float centerX;
  float centerY;
  float sinPos;
  float cosPos;
  float sinNeg;
  float cosNeg;
  float highQuality;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

struct BilinearContribution {
  float alpha;
  float3 premul;
  float3 raw;
};

int clamp_coord(int value, uint limit) {
  return clamp(value, 0, (int)limit - 1);
}

float4 load_clamped(int2 pixel, uint width, uint height) {
  int2 clamped = int2(clamp_coord(pixel.x, width), clamp_coord(pixel.y, height));
  return srcTex.Load(int3(clamped, 0));
}

void accumulate_sample(inout BilinearContribution contribution, float4 sample, float weight) {
  contribution.alpha += sample.a * weight;
  contribution.premul += sample.rgb * sample.a * weight;
  contribution.raw += sample.rgb * weight;
}

BilinearContribution sample_bilinear_legacy(float2 samplePixel, uint width, uint height) {
  int2 base = int2(floor(samplePixel));
  float2 frac = samplePixel - base;
  int x0 = clamp_coord(base.x, width);
  int x1 = clamp_coord(base.x + 1, width);
  int y0 = clamp_coord(base.y, height);
  int y1 = clamp_coord(base.y + 1, height);

  BilinearContribution contribution;
  contribution.alpha = 0.0;
  contribution.premul = float3(0.0, 0.0, 0.0);
  contribution.raw = float3(0.0, 0.0, 0.0);

  accumulate_sample(contribution, srcTex.Load(int3(x0, y0, 0)), (1.0 - frac.x) * (1.0 - frac.y));
  accumulate_sample(contribution, srcTex.Load(int3(x1, y0, 0)), frac.x * (1.0 - frac.y));
  accumulate_sample(contribution, srcTex.Load(int3(x1, y1, 0)), frac.x * frac.y);
  accumulate_sample(contribution, srcTex.Load(int3(x0, y1, 0)), (1.0 - frac.x) * frac.y);
  return contribution;
}

float2 rotate_offset(float2 origin, float2 offset, float sinTheta, float cosTheta) {
  return float2(
      origin.x + offset.x * cosTheta + offset.y * sinTheta,
      origin.y + offset.y * cosTheta - offset.x * sinTheta);
}

float4 sample_nearest_legacy(float2 samplePixel, uint width, uint height) {
  int2 nearest = int2(trunc(samplePixel + 0.5));
  return load_clamped(nearest, width, height);
}

float4 rot_blur(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  uint width, height;
  srcTex.GetDimensions(width, height);

  float2 pixel = floor(pos.xy);
  float2 origin = float2(width * 0.5 + constants.centerX, height * 0.5 + constants.centerY);
  float2 offset = pixel - origin;
  float2 posSamplePixel = rotate_offset(origin, offset, constants.sinPos, constants.cosPos);
  float2 negSamplePixel = rotate_offset(origin, offset, constants.sinNeg, constants.cosNeg);

  if (constants.highQuality > 0.5) {
    BilinearContribution posSample = sample_bilinear_legacy(posSamplePixel, width, height);
    BilinearContribution negSample = sample_bilinear_legacy(negSamplePixel, width, height);
    float alphaSum = posSample.alpha + negSample.alpha;
    if (alphaSum <= 0.0) {
      return float4((posSample.raw + negSample.raw) * 0.5, 0.0);
    }
    return float4((posSample.premul + negSample.premul) / alphaSum, alphaSum * 0.5);
  }

  float4 posSample = sample_nearest_legacy(posSamplePixel, width, height);
  float4 negSample = sample_nearest_legacy(negSamplePixel, width, height);
  float alphaPos = posSample.a;
  float alphaNeg = negSample.a;
  float alphaSum = alphaPos + alphaNeg;
  if (alphaNeg <= 0.0) {
    return float4((posSample.rgb + negSample.rgb) * 0.5, min(alphaSum, 1.0));
  }
  return float4(
      (posSample.rgb * alphaPos + negSample.rgb * alphaNeg) / alphaSum,
      min(alphaSum * 0.5, 1.0));
}
