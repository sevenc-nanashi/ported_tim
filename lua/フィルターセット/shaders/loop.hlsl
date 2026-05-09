Texture2D srcTex : register(t0);
SamplerState srcSampler : register(s0);

float4 loop(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  uint width, height;
  srcTex.GetDimensions(width, height);
  uint shiftedX = (uint)floor(pos.x + width / 2);
  uint shiftedY = (uint)floor(pos.y + height / 2);

  float4 sampled =
      srcTex.Sample(srcSampler, float2(shiftedX % width, shiftedY % height) /
                                    float2(width, height));
  return sampled;
}
