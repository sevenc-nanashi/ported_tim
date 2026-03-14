struct Constants {
  float centerX;
  float centerY;
  float sign;
  float innerScale;
  float outerScale;
  float scaleSum;
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

float4 sample_nearest_legacy(float2 samplePixel, uint width, uint height) {
  int2 nearest = int2(trunc(samplePixel + 0.5));
  return load_clamped(nearest, width, height);
}

float4 rad_blur(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  uint width, height;
  srcTex.GetDimensions(width, height);

  float2 pixel = floor(pos.xy);
  float2 origin =
      float2(width * 0.5 + constants.centerX, height * 0.5 + constants.centerY);
  float2 offset = pixel - origin;
  float2 innerSamplePixel =
      float2(offset.x * constants.innerScale * constants.sign + origin.x,
             offset.y * constants.innerScale * constants.sign + origin.y);
  float2 outerSamplePixel = float2(offset.x * constants.outerScale + origin.x,
                                   offset.y * constants.outerScale + origin.y);

  float4 innerPixel = sample_nearest_legacy(innerSamplePixel, width, height);
  float4 outerPixel = sample_nearest_legacy(outerSamplePixel, width, height);
  float weightedAlpha =
      innerPixel.a * constants.innerScale + outerPixel.a * constants.outerScale;
  float scaleSum = max(constants.scaleSum, 0.000001);
  if (weightedAlpha > 0.0) {
    return float4((innerPixel.rgb * innerPixel.a * constants.innerScale +
                   outerPixel.rgb * outerPixel.a * constants.outerScale) /
                      weightedAlpha,
                  min(weightedAlpha / scaleSum, 1.0));
  }

  return float4((innerPixel.rgb * constants.innerScale +
                 outerPixel.rgb * constants.outerScale) /
                    scaleSum,
                0.0);
}
