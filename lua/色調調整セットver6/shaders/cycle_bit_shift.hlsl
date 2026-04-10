struct Constants {
  float redShift;
  float greenShift;
  float blueShift;
  float cycle24Bit;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState srcSmp : register(s0);

int euclid_mod_i32(int value, int modulus) {
  int result = value % modulus;
  if (result < 0) {
    result += modulus;
  }
  return result;
}

uint normalize_shift8(int value) {
  if (value < 1) {
    return (uint)euclid_mod_i32(-value, 8);
  }
  return 8u - (uint)euclid_mod_i32(value, 8);
}

uint normalize_shift24(int value) {
  if (value < 1) {
    return (uint)euclid_mod_i32(-value, 24);
  }
  return (uint)((((value / 24) + 1) * 24) - value);
}

float4 cycle_bit_shift(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = srcTex.Sample(srcSmp, uv);
  if (rgba.a <= 0.0) {
    return rgba;
  }

  uint r = (uint)round(saturate(rgba.r / rgba.a) * 255.0);
  uint g = (uint)round(saturate(rgba.g / rgba.a) * 255.0);
  uint b = (uint)round(saturate(rgba.b / rgba.a) * 255.0);

  uint outR;
  uint outG;
  uint outB;

  if (constants.cycle24Bit >= 0.5) {
    uint shift = normalize_shift24((int)round(constants.redShift)) & 31u;
    uint rgb = (r << 16) | (g << 8) | b;
    uint rotated = ((rgb >> shift) | (rgb << ((24u - shift) & 31u))) & 0x00ffffffu;
    outB = rotated & 0xffu;
    outG = (rotated >> 8) & 0xffu;
    outR = (rotated >> 16) & 0xffu;
  } else {
    uint shiftB = normalize_shift8((int)round(constants.blueShift)) & 31u;
    uint shiftG = normalize_shift8((int)round(constants.greenShift)) & 31u;
    uint shiftR = normalize_shift8((int)round(constants.redShift)) & 31u;

    outB = (((b << 8) | b) >> shiftB) & 0xffu;
    outG = (((g << 8) | g) >> shiftG) & 0xffu;
    outR = (((r << 8) | r) >> shiftR) & 0xffu;
  }

  return float4(float3(outR, outG, outB) / 255.0, 1.0) * rgba.a;
}
