struct Constants {
  float refR;
  float refG;
  float refB;
  float colorCutAmount;
  float colorDifferenceRange;
  float edge;
  float matchingMethod;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState srcSmp : register(s0);

float3 rgb_to_hsv(float3 rgb) {
  float maxValue = max(rgb.r, max(rgb.g, rgb.b));
  float minValue = min(rgb.r, min(rgb.g, rgb.b));
  float delta = maxValue - minValue;

  float hue = 0.0;
  if (delta > 0.0) {
    if (maxValue == rgb.r) {
      hue = 60.0 * fmod((rgb.g - rgb.b) / delta, 6.0);
    } else if (maxValue == rgb.g) {
      hue = 60.0 * (((rgb.b - rgb.r) / delta) + 2.0);
    } else {
      hue = 60.0 * (((rgb.r - rgb.g) / delta) + 4.0);
    }
  }
  if (hue < 0.0) {
    hue += 360.0;
  }

  float saturation = maxValue <= 0.0 ? 0.0 : delta / maxValue;
  return float3(hue, saturation, maxValue);
}

float3 rgb_to_lab(float3 rgb) {
  float3 rgb255 = rgb * 255.0;
  float xr = (rgb255.r * 0.412453 + rgb255.g * 0.357580 + rgb255.b * 0.180423) /
             98.072;
  float yr =
      (rgb255.r * 0.212671 + rgb255.g * 0.715160 + rgb255.b * 0.072169) / 100.0;
  float zr = (rgb255.r * 0.019334 + rgb255.g * 0.119193 + rgb255.b * 0.950227) /
             118.225;

  float f_x =
      xr <= 0.008856 ? (903.3 * xr + 16.0) / 116.0 : pow(abs(xr), 1.0 / 3.0);
  float f_y =
      yr <= 0.008856 ? (903.3 * yr + 16.0) / 116.0 : pow(abs(yr), 1.0 / 3.0);
  float f_z =
      zr <= 0.008856 ? (903.3 * zr + 16.0) / 116.0 : pow(abs(zr), 1.0 / 3.0);

  return float3(116.0 * f_y - 16.0, 500.0 * (f_x - f_y), 200.0 * (f_y - f_z));
}

float4 leave_color(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float4 rgba = srcTex.Sample(srcSmp, uv);
  if (rgba.a <= 0.0) {
    return rgba;
  }

  float3 refRgb = float3(constants.refR, constants.refG, constants.refB);
  float3 refHsv = rgb_to_hsv(refRgb);
  float3 refLab = rgb_to_lab(refRgb);
  float3 hsv = rgb_to_hsv(rgba.rgb);
  float3 lab = rgb_to_lab(rgba.rgb);

  float distance;
  if (constants.matchingMethod < 1.5) {
    float3 delta = rgba.rgb * 255.0 - refRgb * 255.0;
    distance = length(delta);
  } else if (constants.matchingMethod < 2.5) {
    distance = length(lab.yz - refLab.yz);
  } else if (constants.matchingMethod < 3.5) {
    distance = length(lab - refLab);
  } else {
    distance = abs(hsv.x - refHsv.x) * 255.0;
  }

  float range = max(constants.colorDifferenceRange, 1.0);
  float keepRaw =
      1.0 - ((distance / range) - 1.0) * (2.0 * constants.edge + 1.0) * 0.5;
  float keep = saturate(keepRaw);

  float avg = (rgba.r + rgba.g + rgba.b) / 3.0;
  float3 mixed = rgba.rgb * keep + (1.0 - keep) * avg.xxx;
  float3 outputRgb = mixed * saturate(constants.colorCutAmount) +
                     rgba.rgb * (1.0 - saturate(constants.colorCutAmount));
  return float4(outputRgb, rgba.a);
}
