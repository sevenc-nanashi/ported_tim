struct Constants {
  float strength;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D originalTex : register(t0);
Texture2D blurredTex : register(t1);

float4 unsharp_mask(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  int3 texel = int3(int2(floor(pos.xy)), 0);
  float4 original = originalTex.Load(texel);
  float3 blurred = blurredTex.Load(texel).rgb;
  float amount = clamp(constants.strength, 0.0, 10.0);

  return float4(original.rgb + (original.rgb - blurred) * amount, original.a);
}
