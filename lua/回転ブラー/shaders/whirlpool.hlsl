static const float PI = 3.14159265358979323846;

struct Constants {
  float swirlAmountDeg;
  float radius;
  float centerX;
  float centerY;
  float changeMode;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

int clamp_coord(int value, uint limit) {
  return clamp(value, 0, (int)limit - 1);
}

float4 load_clamped(int2 pixel, uint width, uint height) {
  int2 clamped = int2(clamp_coord(pixel.x, width), clamp_coord(pixel.y, height));
  return srcTex.Load(int3(clamped, 0));
}

float4 sample_nearest_legacy(float2 samplePixel, uint width, uint height) {
  int2 nearest = int2(trunc(samplePixel + 0.5));
  return load_clamped(nearest, width, height);
}

float4 whirlpool(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  uint width, height;
  srcTex.GetDimensions(width, height);

  float2 pixel = floor(pos.xy);
  float2 origin = float2(width * 0.5 + constants.centerX, height * 0.5 + constants.centerY);
  float2 offset = pixel - origin;
  float swirlRad = constants.swirlAmountDeg * PI / 180.0;
  float radiusRecip = 1.0 / max(abs(constants.radius), 1.0);
  float distanceRatio = length(offset) * radiusRecip;
  float angle = constants.changeMode < 0.5
      ? distanceRatio * distanceRatio * swirlRad
      : exp(-4.0 * distanceRatio) * swirlRad;
  float sinTheta = sin(angle);
  float cosTheta = cos(angle);
  float2 samplePixel = float2(
      offset.x * cosTheta + offset.y * sinTheta + origin.x,
      offset.y * cosTheta - offset.x * sinTheta + origin.y);

  return sample_nearest_legacy(samplePixel, width, height);
}
