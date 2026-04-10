struct Constants {
  float red;
  float green;
  float blue;
  float cyan;
  float magenta;
  float yellow;
  float white;
  float gammaExp;
  float useColorize;
  float colorR;
  float colorG;
  float colorB;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState srcSmp : register(s0);

float computeGray(float3 rgb) {
  float m = min(rgb.r, min(rgb.g, rgb.b));
  float dr = rgb.r - m;
  float db = rgb.b - m;
  float dg = rgb.g - m;

  float v31 = min(db, dg);
  float v35 = min(dr, db);
  float v37 = min(dr, dg);

  float v38 = (dr - abs(v35 - v37)) * constants.white;
  float v39 = dg - abs(v31 - v37);
  float v40 = (db - abs(v31 - v35)) * constants.magenta;

  float v41 = v37 * constants.green;
  float v42 = m * constants.red;
  float v43 = v35 * constants.blue;
  float v44 = v31 * constants.cyan;

  float c45 = saturate(v38 + v43 + v41 + v42);
  float c46 = saturate(v41 + v39 * constants.yellow + v44 + v42);
  float c47 = saturate(v42 + v43 + v40 + v44);

  float maxc = max(rgb.r, max(rgb.g, rgb.b));
  float gray = maxc == rgb.r ? c45 : (maxc == rgb.g ? c46 : c47);
  if (constants.gammaExp != 1.0) {
    gray = pow(max(gray, 0.0), constants.gammaExp);
  }
  return saturate(gray);
}

float2 rgbToHs(float3 rgb) {
  float maxc = max(rgb.r, max(rgb.g, rgb.b));
  float minc = min(rgb.r, min(rgb.g, rgb.b));
  float delta = maxc - minc;

  float s = maxc <= 0.0 ? 0.0 : delta / maxc;
  float h = 0.0;
  if (delta > 0.0) {
    if (maxc == rgb.r) {
      h = 60.0 * fmod((rgb.g - rgb.b) / delta, 6.0);
    } else if (maxc == rgb.g) {
      h = 60.0 * (((rgb.b - rgb.r) / delta) + 2.0);
    } else {
      h = 60.0 * (((rgb.r - rgb.g) / delta) + 4.0);
    }
  }

  if (h < 0.0) {
    h += 360.0;
  }
  return float2(h, saturate(s));
}

float3 hsvToRgb(float hDeg, float s, float v) {
  float h = fmod(fmod(hDeg, 360.0) + 360.0, 360.0);
  float c = v * s;
  float x = c * (1.0 - abs(fmod(h / 60.0, 2.0) - 1.0));
  float m = v - c;

  float3 rgb1;
  if (h < 60.0) {
    rgb1 = float3(c, x, 0.0);
  } else if (h < 120.0) {
    rgb1 = float3(x, c, 0.0);
  } else if (h < 180.0) {
    rgb1 = float3(0.0, c, x);
  } else if (h < 240.0) {
    rgb1 = float3(0.0, x, c);
  } else if (h < 300.0) {
    rgb1 = float3(x, 0.0, c);
  } else {
    rgb1 = float3(c, 0.0, x);
  }

  return rgb1 + m;
}

float4 enh_grayscale(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float4 rgba = srcTex.Sample(srcSmp, uv);
  float gray = computeGray(rgba.rgb);

  if (constants.useColorize > 0.5) {
    float2 hs = rgbToHs(float3(constants.colorR, constants.colorG, constants.colorB));
    return float4(hsvToRgb(hs.x, hs.y, gray), rgba.a);
  }

  return float4(gray.xxx, rgba.a);
}
