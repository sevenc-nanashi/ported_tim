struct Constants {
  float threshold;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float3 to_straight_rgb(float4 rgba) {
  return rgba.a > 0.0 ? rgba.rgb / rgba.a : 0.0;
}

float4 note_binarization(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  int2 pixel = int2(floor(pos.xy));
  float4 src = srcTex.Load(int3(pixel, 0));
  float3 rgb = to_straight_rgb(src);
  float value = dot(rgb, float3(1.0, 1.0, 1.0)) <=
                        clamp(constants.threshold, 0.0, 1.0) * 3.0
                    ? 0.0
                    : 1.0;
  return float4(value.xxx, 1.0) * src.a;
}
