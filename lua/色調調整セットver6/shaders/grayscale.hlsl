struct Constants {
  float grayMode;
  float gammaScale;
  float brightR;
  float brightG;
  float brightB;
  float darkR;
  float darkG;
  float darkB;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState srcSmp : register(s0);

float grayscale_value(float3 rgb) {
  if (constants.grayMode < 0.5) {
    return ((rgb.r + rgb.g + rgb.b) / 3.0) * constants.gammaScale;
  }

  if (constants.grayMode < 1.5) {
    return (rgb.r * 0.298912 + rgb.g * 0.58661 + rgb.b * 0.114478) *
           constants.gammaScale;
  }

  float3 linearRgb = pow(max(rgb, 0.0), 2.2);
  float luminance =
      linearRgb.r * 0.222015 + linearRgb.g * 0.706655 + linearRgb.b * 0.07133;
  return constants.gammaScale * pow(max(luminance, 0.0), 1.0 / 2.2);
}

float4 grayscale(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = srcTex.Sample(srcSmp, uv);
  float t = clamp(grayscale_value(rgba.rgb), 0.0, 1.0);
  float3 dark = float3(constants.darkR, constants.darkG, constants.darkB);
  float3 bright =
      float3(constants.brightR, constants.brightG, constants.brightB);
  return float4(lerp(dark, bright, t), rgba.a);
}
