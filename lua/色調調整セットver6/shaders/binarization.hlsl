struct Constants {
  float threshold;
  float grayProcess;
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

float grayscale(float3 rgb) {
  if (constants.grayProcess < 0.5) {
    return (rgb.r + rgb.g + rgb.b) / 3.0;
  }

  if (constants.grayProcess < 1.5) {
    return rgb.r * 0.298912 + rgb.g * 0.58661 + rgb.b * 0.114478;
  }

  float3 linearRgb = pow(max(rgb, 0.0), 2.2);
  float luminance =
      linearRgb.r * 0.222015 + linearRgb.g * 0.706655 + linearRgb.b * 0.07133;
  return pow(max(luminance, 0.0), 1.0 / 2.2);
}

float4 color_binarization(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float4 rgba = srcTex.Sample(srcSmp, uv);
  float gray = grayscale(rgba.rgb);
  float3 bright =
      float3(constants.brightR, constants.brightG, constants.brightB);
  float3 dark = float3(constants.darkR, constants.darkG, constants.darkB);
  float isBright = gray > constants.threshold ? 1.0 : 0.0;

  return float4(lerp(dark, bright, isBright), rgba.a);
}
