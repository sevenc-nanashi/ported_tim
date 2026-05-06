Texture2D srcTex : register(t0);
Texture2D lutTex : register(t1);

float4 tone_curve(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = srcTex.Load(int3(int2(floor(pos.xy)), 0));
  if (rgba.a == 0.0) {
    return rgba;
  }

  int r_index = (int)round(saturate(rgba.r) * 255.0);
  int g_index = (int)round(saturate(rgba.g) * 255.0);
  int b_index = (int)round(saturate(rgba.b) * 255.0);
  float r = lutTex.Load(int3(r_index, 0, 0)).r;
  float g = lutTex.Load(int3(g_index, 0, 0)).g;
  float b = lutTex.Load(int3(b_index, 0, 0)).b;
  return float4(r, g, b, rgba.a);
}
