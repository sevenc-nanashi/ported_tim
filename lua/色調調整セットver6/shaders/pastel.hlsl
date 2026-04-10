struct Constants {
  float saturationScale;
  float brightnessAmount;
  float threshold;
  float softWidth;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState srcSmp : register(s0);

float3 rgb_to_hsv(float3 rgb) {
  float maxValue = max(rgb.r, max(rgb.g, rgb.b));
  float minValue = min(rgb.r, min(rgb.g, rgb.b));
  float delta = maxValue - minValue;

  if (maxValue <= 0.0) {
    return float3(0.0, 0.0, 0.0);
  }

  float hueDeg = 0.0;
  if (delta > 0.0) {
    if (maxValue == rgb.r) {
      hueDeg = 60.0 * ((rgb.g - rgb.b) / delta);
    } else if (maxValue == rgb.g) {
      hueDeg = 60.0 * ((rgb.b - rgb.r) / delta) + 120.0;
    } else {
      hueDeg = 60.0 * ((rgb.r - rgb.g) / delta) + 240.0;
    }
  }

  if (hueDeg < 0.0) {
    hueDeg += 360.0;
  }

  return float3(hueDeg, delta / maxValue, maxValue);
}

float3 hsv_to_rgb(float3 hsv) {
  if (hsv.y <= 0.0) {
    return hsv.zzz;
  }

  float hue = fmod(hsv.x, 360.0);
  if (hue < 0.0) {
    hue += 360.0;
  }

  float hh = hue / 60.0;
  float sector = floor(hh);
  float fraction = hh - sector;

  float p = (1.0 - hsv.y) * hsv.z;
  float q = (1.0 - hsv.y * fraction) * hsv.z;
  float t = (1.0 - hsv.y * (1.0 - fraction)) * hsv.z;

  if (sector < 1.0) {
    return float3(hsv.z, t, p);
  }
  if (sector < 2.0) {
    return float3(q, hsv.z, p);
  }
  if (sector < 3.0) {
    return float3(p, hsv.z, t);
  }
  if (sector < 4.0) {
    return float3(p, q, hsv.z);
  }
  if (sector < 5.0) {
    return float3(t, p, hsv.z);
  }
  return float3(hsv.z, p, q);
}

float4 pastel(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = srcTex.Sample(srcSmp, uv);
  if (rgba.a <= 0.0) {
    return rgba;
  }

  float threshold = saturate(constants.threshold) * 255.0;
  float softWidth = max(constants.softWidth, 0.0);
  float luma = rgba.r * 255.0 * 0.298912 + rgba.g * 255.0 * 0.58661 +
               rgba.b * 255.0 * 0.114478;
  float diff = luma - threshold;

  float3 hsv = rgb_to_hsv(rgba.rgb);
  hsv.y = saturate(hsv.y * saturate(constants.saturationScale));
  hsv.z = saturate((1.0 - saturate(constants.brightnessAmount)) * hsv.z +
                   saturate(constants.brightnessAmount));
  float3 pastelRgb = hsv_to_rgb(hsv);

  float3 outRgb = pastelRgb;
  if (softWidth > 0.0 && diff <= softWidth) {
    if (diff <= 0.0) {
      outRgb = rgba.rgb;
    } else {
      outRgb = lerp(rgba.rgb, pastelRgb, diff / softWidth);
    }
  }

  return float4(outRgb, rgba.a);
}
