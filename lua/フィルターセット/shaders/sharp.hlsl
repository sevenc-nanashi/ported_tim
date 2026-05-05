struct Constants {
  float strength;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float4 sharp(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  uint width, height;
  srcTex.GetDimensions(width, height);

  int2 pixel = int2(floor(pos.xy));
  float4 center = srcTex.Load(int3(pixel, 0));
  if (pixel.x <= 0 || pixel.y <= 0 || pixel.x >= (int)width - 1 ||
      pixel.y >= (int)height - 1) {
    return center;
  }

  float3 north = srcTex.Load(int3(pixel + int2(0, -1), 0)).rgb;
  float3 south = srcTex.Load(int3(pixel + int2(0, 1), 0)).rgb;
  float3 west = srcTex.Load(int3(pixel + int2(-1, 0), 0)).rgb;
  float3 east = srcTex.Load(int3(pixel + int2(1, 0), 0)).rgb;
  float amount = clamp(constants.strength, 0.0, 10.0);
  float3 laplacian = 4.0 * center.rgb - north - south - west - east;
  return float4(center.rgb + laplacian * amount, center.a);
}
