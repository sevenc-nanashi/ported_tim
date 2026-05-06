struct Constants {
  float srcR;
  float srcG;
  float srcB;
  float dstR;
  float dstG;
  float dstB;
  float hueRange;
  float saturationRange;
  float saturationScale;
  float luminanceScale;
  float boundaryAdjust;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float trunc_i32_like(float value) {
  return value < 0.0 ? ceil(value) : floor(value);
}

float positive_mod_360(float value) {
  return value - floor(value / 360.0) * 360.0;
}

float3 rgb_to_hsv_100(float3 rgb) {
  float maxValue = max(rgb.r, max(rgb.g, rgb.b));
  float minValue = min(rgb.r, min(rgb.g, rgb.b));

  if (maxValue <= 0.0) {
    return float3(0.0, 0.0, 0.0);
  }

  if (maxValue == minValue) {
    return float3(0.0, 0.0, trunc_i32_like(maxValue * 100.0 / 255.0));
  }

  float delta = maxValue - minValue;
  float hue;
  if (maxValue == rgb.r) {
    hue = (rgb.g - rgb.b) * 60.0 / delta;
  } else if (maxValue == rgb.g) {
    hue = (rgb.b - rgb.r) * 60.0 / delta + 120.0;
  } else {
    hue = (rgb.r - rgb.g) * 60.0 / delta + 240.0;
  }

  if (hue < 0.0) {
    hue += 360.0;
  }

  return float3(
      trunc_i32_like(hue),
      trunc_i32_like(delta * 100.0 / maxValue),
      trunc_i32_like(100.0 * maxValue / 255.0));
}

float circular_hue_diff(float pixelHue, float sourceHue) {
  if (pixelHue <= sourceHue + 180.0) {
    float diff = pixelHue - sourceHue;
    if (sourceHue > pixelHue + 180.0) {
      diff += 360.0;
    }
    return diff;
  }
  return pixelHue - sourceHue - 360.0;
}

float3 hsv_to_rgb_255(float hue, float saturation, float value) {
  float s = saturation * 0.01;
  float v = value * 0.01;
  float h = positive_mod_360(hue) / 60.0;
  float sector = floor(h);
  float frac = h - sector;

  float p = (1.0 - s) * v;
  float q = (1.0 - frac * s) * v;
  float t = (1.0 - s * (1.0 - frac)) * v;

  float3 rgb;
  if (sector < 1.0) {
    rgb = float3(v, t, p);
  } else if (sector < 2.0) {
    rgb = float3(q, v, p);
  } else if (sector < 3.0) {
    rgb = float3(p, v, t);
  } else if (sector < 4.0) {
    rgb = float3(p, q, v);
  } else if (sector < 5.0) {
    rgb = float3(t, p, v);
  } else {
    rgb = float3(v, p, q);
  }

  return rgb * 255.0;
}

float byte_to_norm(float value) {
  return trunc_i32_like(clamp(value, 0.0, 255.0)) / 255.0;
}

float4 change_to_color(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  int2 pixel = int2(floor(pos.xy));
  float4 src = srcTex.Load(int3(pixel, 0));
  float3 original = src.rgb * 255.0;

  float3 sourceHsv =
      rgb_to_hsv_100(float3(constants.srcR, constants.srcG, constants.srcB));
  float3 destinationHsv =
      rgb_to_hsv_100(float3(constants.dstR, constants.dstG, constants.dstB));
  float3 pixelHsv = rgb_to_hsv_100(original);

  float hueDiff = circular_hue_diff(pixelHsv.x, sourceHsv.x);
  float hueExcess = max(abs(hueDiff) - constants.hueRange, 0.0);
  float saturationExcess =
      max(abs(pixelHsv.y - sourceHsv.y) - constants.saturationRange, 0.0);

  if (hueExcess == 0.0 && saturationExcess == 0.0) {
    pixelHsv.z = trunc_i32_like(pixelHsv.z * constants.luminanceScale);
    pixelHsv.y = trunc_i32_like(pixelHsv.y * constants.saturationScale);
    pixelHsv.x = positive_mod_360(destinationHsv.x + hueDiff + 3600.0);
    pixelHsv.y = min(pixelHsv.y, 100.0);
    pixelHsv.z = min(pixelHsv.z, 100.0);
  }

  float3 outputRgb = hsv_to_rgb_255(pixelHsv.x, pixelHsv.y, pixelHsv.z);

  if (hueExcess == 0.0 && saturationExcess == 0.0) {
    float boundary = max(constants.boundaryAdjust, 0.000001);
    float blend = clamp((abs(hueDiff) - constants.hueRange) / boundary + 1.0,
                        0.0,
                        1.0);
    outputRgb = outputRgb * (1.0 - blend) + original * blend;
  }

  return float4(byte_to_norm(outputRgb.r),
                byte_to_norm(outputRgb.g),
                byte_to_norm(outputRgb.b),
                src.a);
}
