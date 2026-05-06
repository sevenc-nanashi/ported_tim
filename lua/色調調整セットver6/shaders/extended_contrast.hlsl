struct Constants {
  float center;
  float intensity;
  float brightness;
  float smooth;
};

cbuffer constants : register(b0) { Constants constants; }
Texture2D srcTex : register(t0);

float map_extended_contrast_value(float src) {
  float value255 = floor(clamp(src, 0.0, 1.0) * 255.0 + 0.5);
  float shifted = -128.0 - constants.center + value255;
  float v = clamp(shifted * constants.intensity + 128.0, 0.0, 255.0);
  float t = v / 255.0;
  float invSmooth = 1.0 - constants.smooth;
  float curved =
      (t * invSmooth + (3.0 - t * 2.0) * (t * t) * constants.smooth) *
          255.0 +
      constants.brightness;
  return floor(clamp(curved, 0.0, 255.0)) / 255.0;
}

float4 extended_contrast(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  int2 pixel = int2(floor(pos.xy));
  float4 src = srcTex.Load(int3(pixel, 0));
  return float4(map_extended_contrast_value(src.r),
                map_extended_contrast_value(src.g),
                map_extended_contrast_value(src.b),
                src.a);
}

float4 extended_contrast_curve(float4 pos : SV_Position, float2 uv : TEXCOORD0)
    : SV_TARGET {
  uint texWidth, texHeight;
  srcTex.GetDimensions(texWidth, texHeight);

  float width = (float)texWidth;
  float height = (float)texHeight;
  float2 pixel = floor(pos.xy);

  if (width <= 0.0 || height <= 0.0) {
    return float4(0.0, 0.0, 0.0, 0.0);
  }

  if (pixel.x < 2.0 || pixel.x > width - 3.0 || pixel.y < 2.0 ||
      pixel.y > height - 3.0) {
    return float4(1.0, 0.0, 0.0, 1.0);
  }

  float rowValue = 255.0 * max(height - pixel.y - 3.0, 0.0);
  float rowCurveY = height > 5.0 ? floor(rowValue / (height - 5.0)) : 0.0;
  float colValue = max(255.0 * pixel.x - 510.0, 0.0);
  float curveIndex = height > 0.0 && width > 5.0
                         ? floor(colValue / (width - 5.0))
                         : 0.0;
  float lutY = map_extended_contrast_value(clamp(curveIndex, 0.0, 255.0) / 255.0) *
               255.0;

  return rowCurveY > lutY ? float4(0.0, 0.0, 0.0, 1.0)
                          : float4(1.0, 1.0, 1.0, 1.0);
}
