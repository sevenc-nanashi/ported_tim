struct Constants {
  float u;
  float v;
  float gamma;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float4 monochromatic2(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  int2 pixel = int2(floor(pos.xy));
  float4 src = srcTex.Load(int3(pixel, 0));
  float3 rgb255 = src.rgb * 255.0;
  float gamma = max(constants.gamma, 0.0001);
  float luma = (rgb255.b * 0.456 + rgb255.g * 2.348 + rgb255.r * 1.196) / 1023.0;
  float idx = clamp(floor(pow(max(luma, 0.0), 1.0 / gamma) * 1023.0), 0.0, 1023.0);
  float base = idx * 0.25;

  float outR = clamp(constants.u * 357.663 + base, 0.0, 255.0);
  float outG = clamp(base - constants.v * 87.822 - constants.u * 181.407, 0.0, 255.0);
  float outB = clamp(base + constants.v * 441.915, 0.0, 255.0);

  return float4(floor(float3(outR, outG, outB)) / 255.0, src.a);
}
