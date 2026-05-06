struct Constants {
  float mode;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float4 flat_rgb(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  int2 pixel = int2(floor(pos.xy));
  float4 src = srcTex.Load(int3(pixel, 0));
  int mode = (int)round(constants.mode);

  if (mode == 1) {
    return float4(src.r, 0.5, 0.5, src.a);
  }
  if (mode == 2) {
    return float4(0.5, src.g, 0.5, src.a);
  }
  return float4(0.5, 0.5, src.b, src.a);
}
