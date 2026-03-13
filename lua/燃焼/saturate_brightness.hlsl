Texture2D<float4> SrcTex : register(t0);
SamplerState SrcSmp : register(s0);

float4 saturate_brightness(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float4 rgba = SrcTex.Sample(SrcSmp, uv);
  const float brightness = 3.5;
  return float4(clamp(rgba.r, 0.0, brightness), clamp(rgba.g, 0.0, brightness),
                clamp(rgba.b, 0.0, brightness), rgba.a);
}

// vim:set ft=hlsl:
