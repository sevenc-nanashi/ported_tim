struct Constants {
  float flipLower;
  float flipUpper;
  float grayMode;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState srcSmp : register(s0);

float grayscale(float3 rgb) {
  float3 rgb255 = rgb * 255.0;

  if (constants.grayMode < 0.5) {
    return (rgb255.r + rgb255.g + rgb255.b) / 3.0;
  }

  if (constants.grayMode < 1.5) {
    return rgb255.r * 0.298912 + rgb255.g * 0.58661 + rgb255.b * 0.114478;
  }

  float3 linearRgb = pow(max(rgb, 0.0), 2.2);
  float luminance =
      linearRgb.r * 0.222015 + linearRgb.g * 0.706655 + linearRgb.b * 0.07133;
  return pow(max(luminance, 0.0), 1.0 / 2.2) * 255.0;
}

float metalValue(float gray) {
  int lutIndex = clamp((int)(gray * 4.0), 0, 1020);
  float x = min((float)lutIndex * 0.25, 255.0);

  float lower = constants.flipLower * 255.0;
  float upper = constants.flipUpper * 255.0;
  float value;

  if (x >= lower) {
    if (upper > x) {
      value = upper == lower ? 0.0 : (upper - x) * 255.0 / (upper - lower);
    } else {
      value = upper == 255.0 ? 255.0 : (x - upper) * 255.0 / (255.0 - upper);
    }
  } else {
    value = lower == 0.0 ? 255.0 : x * 255.0 / lower;
  }

  return clamp(value / 255.0, 0.0, 1.0);
}

float4 metal(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = srcTex.Sample(srcSmp, uv);
  float gray = grayscale(rgba.rgb);
  float value = metalValue(gray);
  return float4(value, value, value, rgba.a);
}
