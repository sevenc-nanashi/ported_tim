struct Constants {
  float width;
  float height;
  float alphaThreshold;
  float blur;
  float distance;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D<float4> SrcTex : register(t0);
SamplerState SrcSmp : register(s0);

float unlerpClamped(float min, float max, float value) {
  if (max - min == 0.0) {
    return 0.0;
  }
  return clamp((value - min) / (max - min), 0.0, 1.0);
}

float4 distance_map(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float4 rgba = SrcTex.Sample(SrcSmp, uv);

  float minDistance = constants.distance;
  for (int dx = floor(-constants.distance); dx <= ceil(constants.distance);
       dx++) {
    for (int dy = floor(-constants.distance); dy <= ceil(constants.distance);
         dy++) {
      if (dx * dx + dy * dy <= constants.distance * constants.distance) {
        float2 offsetUV =
            uv + float2(dx / constants.width, dy / constants.height);
        float4 offsetSample = SrcTex.Sample(SrcSmp, offsetUV);
        if (offsetSample.a > constants.alphaThreshold) {
          float distance = length(float2(dx, dy));
          minDistance = min(minDistance, distance);
        }
      }
    }
  }

  // float3 col1 = float3(constants.col1R, constants.col1G, constants.col1B);
  // float3 col2 = float3(constants.col2R, constants.col2G, constants.col2B);
  // float3 color = lerp(col1, col2, 1.0 - minDistance / constants.distance);

  float a = smoothstep(0.0, 1.0,
                       unlerpClamped(constants.distance,
                                     constants.distance - constants.blur,
                                     minDistance));
  float colorLevel = 1.0 - minDistance / constants.distance;
  return float4(colorLevel, a, 0.0, 1.0);
}
