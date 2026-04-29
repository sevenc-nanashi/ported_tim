struct Constants {
  float adjustMethod;
  float alphaUpperLimit;
  float alphaLowerLimit;
  float bgR;
  float bgG;
  float bgB;
  float applyAlphaAfter;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

int div_trunc_zero(int numerator, int denominator) {
  return int((float)numerator / (float)denominator);
}

int alpha_lut(int alphaValue) {
  int hi = int(round(constants.alphaUpperLimit));
  int lo = int(round(constants.alphaLowerLimit));
  if (hi < lo) {
    int tmp = hi;
    hi = lo;
    lo = tmp;
  }

  if (hi == lo) {
    return alphaValue < lo ? 0 : 255;
  }

  int value = div_trunc_zero((alphaValue - lo) * 255, hi - lo);
  return clamp(value, 0, 255);
}

float4 fringe_fix(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = srcTex.Load(int3(int2(floor(pos.xy)), 0));
  int b = int(round(rgba.b * 255.0));
  int g = int(round(rgba.g * 255.0));
  int r = int(round(rgba.r * 255.0));
  int a = int(round(rgba.a * 255.0));
  int bgB = int(round(constants.bgB));
  int bgG = int(round(constants.bgG));
  int bgR = int(round(constants.bgR));
  bool applyAlphaAfter = constants.applyAlphaAfter > 0.5;

  if (!applyAlphaAfter) {
    a = alpha_lut(clamp(a, 0, 255));
  }

  if (a >= 1 && a <= 254) {
    int method = int(round(constants.adjustMethod));
    if (method == 1) {
      int inv = 255 - a;
      b = clamp(div_trunc_zero(b * 255 - inv * bgB, a), 0, 255);
      g = clamp(div_trunc_zero(g * 255 - inv * bgG, a), 0, 255);
      r = clamp(div_trunc_zero(r * 255 - inv * bgR, a), 0, 255);
    } else if (method == 2) {
      b = bgB;
      g = bgG;
      r = bgR;
    } else if (method == 3) {
      int inv = 255 - a;
      b = div_trunc_zero(inv * bgB + b * a, 255);
      g = div_trunc_zero(inv * bgG + g * a, 255);
      r = div_trunc_zero(inv * bgR + r * a, 255);
    }
  }

  if (applyAlphaAfter) {
    a = alpha_lut(clamp(a, 0, 255));
  }

  return float4(r / 255.0, g / 255.0, b / 255.0, a / 255.0);
}
