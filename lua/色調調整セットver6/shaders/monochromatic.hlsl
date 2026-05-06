struct Constants {
  float offsetR;
  float offsetG;
  float offsetB;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float4 monochromatic(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  int2 pixel = int2(floor(pos.xy));
  float4 src = srcTex.Load(int3(pixel, 0));
  float3 rgb255 = src.rgb * 255.0;
  float gray = floor(dot(rgb255, float3(0.298912, 0.58661, 0.114478)));
  float3 mapped =
      min(gray.xxx + float3(constants.offsetR, constants.offsetG, constants.offsetB),
          255.0);
  return float4(mapped / 255.0, src.a);
}
