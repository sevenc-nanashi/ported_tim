struct Constants {
  float minValue;
  float maxValue;
  float calcMethod;
  float active;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
Texture2D lutTex : register(t1);

float byte_to_unit(float value) {
  return floor(clamp(value, 0.0, 255.0)) / 255.0;
}

float decode_lut(int index) {
  float4 encoded = lutTex.Load(int3(index, 0, 0));
  float hi = floor(encoded.r * 255.0 + 0.5);
  float lo = floor(encoded.g * 255.0 + 0.5);
  return (hi * 256.0 + lo) / 256.0;
}

float scale_byte(float value, float invRange) {
  return (value - constants.minValue) * 255.0 * invRange;
}

float4 equalize(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  float4 rgba = srcTex.Load(int3(int2(floor(pos.xy)), 0));
  if (constants.active < 0.5 || rgba.a == 0.0) {
    return rgba;
  }

  float invRange = 1.0 / (constants.maxValue - constants.minValue);
  float r = rgba.r * 255.0;
  float g = rgba.g * 255.0;
  float b = rgba.b * 255.0;

  float rScaled = scale_byte(r, invRange);
  float gScaled = scale_byte(g, invRange);
  float bScaled = scale_byte(b, invRange);

  if (constants.calcMethod > 1.5) {
    return float4(byte_to_unit(rScaled), byte_to_unit(gScaled),
                  byte_to_unit(bScaled), rgba.a);
  }

  float y =
      (rScaled * 0.298912 + gScaled * 0.58661 + bScaled * 0.114478) * 4.0;
  float u = bScaled * 0.436 - (gScaled * 0.289 + rScaled * 0.147);
  float v = rScaled * 0.615 - gScaled * 0.515 - bScaled * 0.1;

  float yFloor = floor(y);
  int y0 = min((int)yFloor, 1020);
  int y1 = min((int)yFloor + 1, 1020);
  float frac = y - yFloor;
  float yEq = lerp(decode_lut(y0), decode_lut(y1), frac);

  float outR = yEq + v * 1.14;
  float outG = yEq - u * 0.394 - v * 0.581;
  float outB = yEq + u * 2.032;
  return float4(byte_to_unit(outR), byte_to_unit(outG), byte_to_unit(outB),
                rgba.a);
}
