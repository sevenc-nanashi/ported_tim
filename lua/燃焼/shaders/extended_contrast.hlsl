struct Constants {
  float t;
  float ecw;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D<float4> SrcTex : register(t0);
SamplerState SrcSmp : register(s0);

static const float PI = 3.1415926535897932384626433832795;

float convertTable(float value) {
  float ecwClamped = clamp(constants.ecw, -200.0, 200.0);
  float coeff = tan(PI * ecwClamped * 0.0025);
  float shifted = value - 0.5 - constants.t / 255.0;
  float v = shifted * coeff + 0.5;
  return clamp(v, 0.0, 1.0);
}

float4 extended_contrast(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float4 rgba = SrcTex.Sample(SrcSmp, uv);
  float r = convertTable(rgba.r);
  float g = convertTable(rgba.g);
  float b = convertTable(rgba.b);
  return float4(r, g, b, rgba.a);
}
