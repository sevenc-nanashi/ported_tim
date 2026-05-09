struct Constants {
  float seed;
  float length;
  float threshold;
  float whiteLineAmount;
  float blackLineAmount;
  float dx;
  float dy;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState linearSampler : register(s0);

struct VSOut {
  float4 Position : SV_Position;
  float2 UV : TEXCOORD0;
};

uint hash(uint x) {
  x ^= x >> 16;
  x *= 0x7feb352d;
  x ^= x >> 15;
  x *= 0x846ca68b;
  x ^= x >> 16;
  return x;
}

float rand01(uint x) { return (hash(x) & 0x00FFFFFFu) / 16777215.0; }

float getGray(int2 p) {
  float4 pix = srcTex.Load(int3(p, 0));
  return pix.a > 0.0 ? pix.r / pix.a : 0.0;
}

float lutValue(float px, float th) {
  if (px < th) {
    float lowDen = th + 1.0;
    return 1.0 - ((px + 1.0) / lowDen);
  } else {
    float highDen = (255.0 - th) + 1.0;
    return (px - th) / highDen;
  }
}

float4 graphicpen(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  int2 p = int2(floor(pos.xy));
  float grayF = getGray(p) * 255.0;
  float alpha = srcTex.Load(int3(p, 0)).a;
  uint gray = (uint)round(grayF);
  uint width, height;
  srcTex.GetDimensions(width, height);

  uint th = (uint)clamp((float)constants.threshold, 0.0, 255.0);

  int sign = constants.dx;
  int dirFlag = constants.dy;
  int lenEff = (int)round(constants.length);

  lenEff = max(lenEff, 0);

  int2 step = int2(dirFlag, sign);

  float whiteAdj = 1.0 - constants.whiteLineAmount * 2.0;
  float blackAdj = 1.0 - constants.blackLineAmount * 2.0;

  bool influenced = false;
  float influencedValue = 0.0;

  // 周囲のピクセルが自分へ線を引くか確認
  for (int i = -lenEff; i <= lenEff; i++) {
    int2 origin = p - step * i;

    if (origin.x < 0 || origin.y < 0 || origin.x >= (int)width ||
        origin.y >= (int)height) {
      continue;
    }

    float originGrayF = getGray(origin) * 255.0;
    uint originGray = (uint)round(originGrayF);

    uint idx = origin.x + origin.y * width;

    uint seedBase = hash(uint(constants.seed * 65536.0));

    float r0 = rand01(seedBase ^ idx ^ 0x12345678u);
    float r1 = rand01(seedBase ^ idx ^ 0x87654321u);

    float lut = lutValue(originGrayF, th);

    bool draw = false;
    float value = 0.0;

    if (originGray <= th) {
      if (lut + whiteAdj < r0) {
        draw = true;
        value = 1.0;
      }
    } else {
      if (lut + blackAdj < r0) {
        draw = true;
        value = 0.0;
      }
    }

    if (!draw)
      continue;

    float d = float(lenEff) * r1 + 1.0;

    int start = int(round(d * -0.5));
    int end = int(round(d * 0.5));

    if (i >= start && i < end) {
      influenced = true;
      influencedValue = value;
    }
  }

  float finalValue;

  if (influenced) {
    finalValue = influencedValue;
  } else {
    finalValue = (gray <= th) ? 0.0 : 1.0;
  }

  return float4(finalValue.xxx, 1.0) * alpha;
}
