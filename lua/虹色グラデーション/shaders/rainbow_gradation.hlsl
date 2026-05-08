struct Constants {
  float mixRate;
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

float smooth_mix(float t, float mixRate) {
  t = saturate(t);
  float smooth = t * t * (3.0 - 2.0 * t);
  return lerp(smooth, t, mixRate);
}

float ramp_up(float phase, float start, float end, float mixRate) {
  return smooth_mix((phase - start) / (end - start), mixRate);
}

float ramp_down(float phase, float start, float end, float mixRate) {
  return 1.0 - ramp_up(phase, start, end, mixRate);
}

float3 rainbow_to_rgb(float phase, float mixRate) {
  float r = 0.0;
  float g = 0.0;
  float b = 0.0;

  if (phase < 1.0 / 6.0) {
    r = 1.0;
    g = ramp_up(phase, 0.0, 1.0 / 6.0, mixRate);
  } else if (phase < 1.0 / 3.0) {
    r = ramp_down(phase, 1.0 / 6.0, 1.0 / 3.0, mixRate);
    g = 1.0;
  } else if (phase < 0.5) {
    g = 1.0;
    b = ramp_up(phase, 1.0 / 3.0, 0.5, mixRate);
  } else if (phase < 2.0 / 3.0) {
    g = ramp_down(phase, 0.5, 2.0 / 3.0, mixRate);
    b = 1.0;
  } else if (phase < 5.0 / 6.0) {
    r = ramp_up(phase, 2.0 / 3.0, 5.0 / 6.0, mixRate);
    b = 1.0;
  } else {
    r = 1.0;
    b = ramp_down(phase, 5.0 / 6.0, 1.0, mixRate);
  }

  return float3(r, g, b);
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
  float mixRate = clamp(constants.mixRate * 0.01, 0.0, 1.0);
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

  float3 rgb = rainbow_to_rgb(phase, mixRate);
  rgb = round(rgb * 255.0) / 255.0;
  return float4(rgb * src.a, src.a);
}
