struct Constants {
  float saturation;
  float shrinkRate;
  float rotationRad;
  float reverse;
  float circular;
  float shift;
  float repeatMode;
  float boundaryCorrection;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float frac01(float value) { return value - floor(value); }

float apply_boundary_correction(float t, float dc) {
  if (dc <= 0.0) {
    return t;
  }

  float clampedDc = min(dc, 0.49);
  float span = 1.0 - clampedDc * 2.0;
  if (span <= 0.0) {
    return 0.5;
  }

  return clamp((t - clampedDc) / span, 0.0, 1.0);
}

float3 hsv_to_rgb(float h, float s, float v) {
  float wrappedHue = frac01(h) * 6.0;
  float sector = floor(wrappedHue);
  float t = wrappedHue - sector;

  float p = v * (1.0 - s);
  float q = v * (1.0 - s * t);
  float u = v * (1.0 - s * (1.0 - t));

  if (sector < 1.0) {
    return float3(v, u, p);
  }
  if (sector < 2.0) {
    return float3(q, v, p);
  }
  if (sector < 3.0) {
    return float3(p, v, u);
  }
  if (sector < 4.0) {
    return float3(p, q, v);
  }
  if (sector < 5.0) {
    return float3(u, p, v);
  }
  return float3(v, p, q);
}

float4 rainbow_gradation(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  uint width, height;
  srcTex.GetDimensions(width, height);

  float4 src = srcTex.Load(int3(int2(floor(pos.xy)), 0));
  if (width == 0 || height == 0) {
    return src;
  }

  float w = width;
  float h = height;
  float hw = w * 0.5;
  float hh = h * 0.5;
  float2 pixel = floor(pos.xy);
  float dx = pixel.x - hw;
  float dy = pixel.y - hh;

  float sinR = sin(constants.rotationRad);
  float cosR = cos(constants.rotationRad);
  float sat = clamp(constants.saturation * 0.01, 0.0, 1.0);
  float shift01 = constants.shift * 0.01;
  float dc = max(constants.boundaryCorrection, 0.0);
  float linearDen = h * h * sinR * sinR + w * w * cosR * cosR;

  float base = 0.0;
  if (constants.circular <= 0.5) {
    if (linearDen == 0.0) {
      base = 0.5;
    } else {
      float n = sinR * h * (sinR * hh + dy) + cosR * w * (cosR * hw + dx);
      base = n / linearDen;
    }
  } else {
    float ny = hh > 0.0 ? dy / hh : 0.0;
    float nx = hw > 0.0 ? dx / hw : 0.0;
    base = sqrt(nx * nx + ny * ny);
  }

  float t = (base - 0.5) * constants.shrinkRate + 0.5;
  if (constants.repeatMode > 0.5) {
    t = frac01(t);
  } else {
    t = clamp(t, 0.0, 1.0);
  }

  if (constants.reverse > 0.5) {
    t = (1.0 - t) + shift01;
  } else {
    t = t - shift01;
  }

  float phase = frac01(t);
  float segment = phase * 6.0;
  float segmentIndex = floor(segment);
  float segmentT = apply_boundary_correction(segment - segmentIndex, dc);
  phase = (segmentIndex + segmentT) / 6.0;

  float3 rgb = hsv_to_rgb(phase, sat, 1.0);
  rgb = round(rgb * 255.0) / 255.0;
  return float4(rgb, src.a);
}
