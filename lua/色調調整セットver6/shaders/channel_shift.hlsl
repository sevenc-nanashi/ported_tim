struct Constants {
  float alphaSource;
  float redSource;
  float greenSource;
  float blueSource;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState srcSmp : register(s0);

float3 to_straight_rgb(float4 rgba) {
  return rgba.a > 0.0 ? rgba.rgb / rgba.a : float3(0.0, 0.0, 0.0);
}

float3 rgb_to_hsv_255(float3 rgb) {
  float maxValue = max(rgb.r, max(rgb.g, rgb.b));
  float minValue = min(rgb.r, min(rgb.g, rgb.b));
  float delta = maxValue - minValue;

  float hueDeg = 0.0;
  if (delta > 0.0) {
    if (maxValue == rgb.r) {
      hueDeg = 60.0 * fmod((rgb.g - rgb.b) / delta, 6.0);
    } else if (maxValue == rgb.g) {
      hueDeg = 60.0 * (((rgb.b - rgb.r) / delta) + 2.0);
    } else {
      hueDeg = 60.0 * (((rgb.r - rgb.g) / delta) + 4.0);
    }
  }

  if (hueDeg < 0.0) {
    hueDeg += 360.0;
  }

  float saturation = maxValue <= 0.0 ? 0.0 : delta / maxValue;
  float value = maxValue;

  return float3(hueDeg / 360.0, saturation, value);
}

float pick_channel(float4 rgba, float3 straightRgb, float3 hsv255, float source) {
  if (source < 0.5) {
    return rgba.a;
  }
  if (source < 1.5) {
    return straightRgb.r;
  }
  if (source < 2.5) {
    return straightRgb.g;
  }
  if (source < 3.5) {
    return straightRgb.b;
  }
  if (source < 4.5) {
    return hsv255.x;
  }
  if (source < 5.5) {
    return hsv255.y;
  }
  return hsv255.z;
}

float4 channel_shift(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = srcTex.Sample(srcSmp, uv);
  float3 straightRgb = to_straight_rgb(rgba);
  float3 hsv255 = rgb_to_hsv_255(straightRgb);

  float outAlpha = pick_channel(rgba, straightRgb, hsv255, constants.alphaSource);
  float3 outStraightRgb = float3(
      pick_channel(rgba, straightRgb, hsv255, constants.redSource),
      pick_channel(rgba, straightRgb, hsv255, constants.greenSource),
      pick_channel(rgba, straightRgb, hsv255, constants.blueSource));

  return float4(outStraightRgb * outAlpha, outAlpha);
}
