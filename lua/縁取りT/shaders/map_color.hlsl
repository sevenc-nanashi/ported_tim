struct Constants {
  float col1R;
  float col1G;
  float col1B;
  float col2R;
  float col2G;
  float col2B;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D<float4> SrcTex : register(t0);
SamplerState SrcSmp : register(s0);

float4 ENTRY_NAME(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = SrcTex.Sample(SrcSmp, uv);

  float3 col1 = float3(constants.col1R, constants.col1G, constants.col1B);
  float3 col2 = float3(constants.col2R, constants.col2G, constants.col2B);
  float3 color = lerp(col1, col2, rgba.r);

  return float4(color, 1.0) *
#if WITH_ALPHA
         rgba.g
#else
         1.0
#endif
      ;
}
