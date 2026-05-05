struct Constants {
  float r1;
  float g1;
  float b1;
  float r2;
  float g2;
  float b2;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float3 to_straight_rgb(float4 rgba) {
  return rgba.a > 0.0 ? rgba.rgb / rgba.a : 0.0;
}

float4 blaster_gray_color(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  int2 pixel = int2(floor(pos.xy));
  float4 src = srcTex.Load(int3(pixel, 0));
  float3 shadow = float3(constants.r1, constants.g1, constants.b1);
  float3 highlight = float3(constants.r2, constants.g2, constants.b2);
  float gray = to_straight_rgb(src).b;
  return float4(lerp(shadow, highlight, gray), 1.0) * src.a;
}
