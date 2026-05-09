struct Constants {
  float divide;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState srcSampler : register(s0);

float flatten_channel(float value) {
  int src = (int)floor(clamp(value, 0.0, 1.0) * 255.0 + 0.5);
  float scale = constants.divide * 0.5 * 255.0;
  int low = (int)(127.5 - scale);
  int high = (int)((127.5 - scale) + 127.5);
  float mapped = 128.0;

  if (low > 0 && src < low) {
    mapped = floor((float(src) * 128.0) / float(low));
  } else if (high < 256 && src >= max(high, 0)) {
    int den = 256 - high;
    if (den > 0) {
      mapped =
          128.0 + floor((float(src - max(high, 0) + 1) * 127.0) / float(den));
    }
  }

  return clamp(mapped, 0.0, 255.0) / 255.0;
}

float4 flattening(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 src = srcTex.Sample(srcSampler, uv);
  return float4(flatten_channel(src.r), flatten_channel(src.g),
                flatten_channel(src.b), src.a);
}
