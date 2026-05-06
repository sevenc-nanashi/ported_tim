struct Constants {
  float blackCrushAdjust;
  float whiteClipAdjust;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D originalTex : register(t0);
Texture2D blurredTex : register(t1);

float shadow_highlight_map(float value, float luma) {
  float delta = constants.whiteClipAdjust - constants.blackCrushAdjust;
  float adjust = luma / 256.0 * delta + constants.blackCrushAdjust;

  if (adjust < 0.0) {
    float mapped =
        255.0 - floor(pow(max(1.0 - value, 0.0), 1.0 - adjust) * 255.0);
    return clamp(mapped / 255.0, 0.0, 1.0);
  }

  float mapped = floor(pow(max(value, 0.0), 1.0 + adjust) * 255.0);
  return clamp(mapped / 255.0, 0.0, 1.0);
}

float4 shadow_highlight(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  int3 texel = int3(int2(floor(pos.xy)), 0);
  float4 original = originalTex.Load(texel);
  float4 blurred = blurredTex.Load(texel);
  float luma =
      floor(clamp(dot(blurred.rgb, float3(0.298912, 0.58661, 0.114478)) * 255.0,
                  0.0, 255.0));

  return float4(shadow_highlight_map(original.r, luma),
                shadow_highlight_map(original.g, luma),
                shadow_highlight_map(original.b, luma),
                shadow_highlight_map(original.a, luma));
}
