struct Constants {
  float width;
  float height;
  float splitX;
  float splitY;
  float cellWidth;
  float cellHeight;
  float shift;
  float thin;
  float range;
  float reverse;
  float hideBackground;
  float lineColor;
  float backgroundColor;
};

cbuffer constants : register(b0) { Constants constants; }

Texture2D srcTex : register(t0);
SamplerState srcSmp : register(s0);

float3 color_from_int(float color) {
  uint c = (uint)round(color);
  return float3((c >> 16) & 0xff, (c >> 8) & 0xff, c & 0xff) / 255.0;
}

float luma_yc(float3 rgb) {
  return dot(rgb, float3(0.298912, 0.58661, 0.114478));
}

float4 linetone_t(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float2 imageSize = max(float2(constants.width, constants.height), 1.0);
  float x = clamp(pos.x, 0.0, imageSize.x - 0.5);
  float y = pos.y;
  float i = clamp(floor(x / constants.cellWidth), 0.0,
                  max(constants.splitX - 1.0, 0.0));
  float j = floor((y - constants.shift) / constants.cellHeight);
  float2 samplePos = float2((i + 0.5) * constants.cellWidth,
                            (j + 0.5) * constants.cellHeight + constants.shift);
  samplePos = clamp(samplePos, float2(0.5, 0.5), imageSize - 0.5);

  float4 src = srcTex.Sample(srcSmp, samplePos / imageSize);
  float lum = luma_yc(src.rgb);
  float tone = constants.reverse < 0.5 ? 1.0 - lum : lum;
  float halfWidth =
      constants.cellHeight * (constants.thin + tone * constants.range) * 0.5;
  float centerY = (j + 0.5) * constants.cellHeight + constants.shift;
  float isLine = abs(y - centerY) <= halfWidth ? 1.0 : 0.0;

  float4 bg = constants.hideBackground < 0.5
                  ? float4(color_from_int(constants.backgroundColor), 1.0)
                  : float4(0.0, 0.0, 0.0, 0.0);
  float4 line_ = float4(color_from_int(constants.lineColor), 1.0);
  return lerp(bg, line_, isLine);
}
