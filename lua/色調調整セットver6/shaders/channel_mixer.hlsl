
struct Constants {
  float redToRed;
  float greenToRed;
  float blueToRed;
  float constantRed;
  float redToGreen;
  float greenToGreen;
  float blueToGreen;
  float constantGreen;
  float redToBlue;
  float greenToBlue;
  float blueToBlue;
  float constantBlue;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);
SamplerState srcSmp : register(s0);

float4 channel_mixer(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = srcTex.Sample(srcSmp, uv);
  float4 straight = rgba.a > 0.0 ? rgba / rgba.a : float4(0.0, 0.0, 0.0, 0.0);

  float red = straight.r * constants.redToRed +
              straight.g * constants.greenToRed +
              straight.b * constants.blueToRed + constants.constantRed;
  float green = straight.r * constants.redToGreen +
                straight.g * constants.greenToGreen +
                straight.b * constants.blueToGreen + constants.constantGreen;
  float blue = straight.r * constants.redToBlue +
               straight.g * constants.greenToBlue +
               straight.b * constants.blueToBlue + constants.constantBlue;

  return float4(red, green, blue, 1.0) * rgba.a;
}
