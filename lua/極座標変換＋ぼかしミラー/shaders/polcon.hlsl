static const float PI = 3.14159265358979323846;

struct Constants {
  float width;
  float height;
  float range;
  float applyAmount;
  float mode; // 0: conversion, 1: inversion
  float radiusX;
  float radiusY;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState srcSmp : register(s0);

float4 polar_conversion(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float2 center = float2(constants.width, constants.height) * 0.5;
  float a = constants.applyAmount;
  float b = 1.0 - a;

  if (constants.mode < 0.5) {
    // polar_conversion
    float2 n = (pos.xy - center) / float2(constants.radiusX, constants.radiusY);
    float theta = atan2(n.x, n.y);
    float r = length(n);
    float sx = (theta / PI + 1.0) * 0.5;
    float sy = r;
    float2 uv_s = float2(sx, sy);
    float2 uv_final = lerp(uv, uv_s, a);

    if (uv_final.x < 0.0 || uv_final.x > 1.0 || uv_final.y < 0.0 ||
        uv_final.y > 1.0) {
      return float4(0, 0, 0, 0);
    }
    return srcTex.Sample(srcSmp, uv_final);
  } else {
    // polar_inversion
    float theta = (2.0 * uv.x - 1.0) * PI;
    float t = uv.y;
    float sx = center.x + sin(theta) * (constants.radiusX * t);
    float sy = center.y + cos(theta) * (constants.radiusY * t);

    float2 uv_s = float2(sx / constants.width, sy / constants.height);
    float2 uv_final = lerp(uv, uv_s, a);

    if (uv_final.x < 0.0 || uv_final.x > 1.0 || uv_final.y < 0.0 ||
        uv_final.y > 1.0) {
      return float4(0, 0, 0, 0);
    }
    return srcTex.Sample(srcSmp, uv_final);
  }
}
