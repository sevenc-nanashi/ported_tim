Texture2D srcTex : register(t0);

void paint_horizontal_pair(int2 pixel, int width, int height, int n,
                           float3 topColor, float3 bottomColor,
                           inout float3 color) {
  if (width <= n * 2 || height < n) {
    return;
  }

  if (pixel.x >= n && pixel.x < width - n) {
    if (pixel.y == n - 1) {
      color = topColor;
    } else if (pixel.y == height - n) {
      color = bottomColor;
    }
  }
}

void paint_vertical_pair(int2 pixel, int width, int height, int n,
                         float3 leftColor, float3 rightColor,
                         inout float3 color) {
  if (height <= n * 2 || width < n) {
    return;
  }

  if (pixel.y >= n && pixel.y < height - n) {
    if (pixel.x == n - 1) {
      color = leftColor;
    } else if (pixel.x == width - n) {
      color = rightColor;
    }
  }
}

float4 glass_sq(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  uint texWidth, texHeight;
  srcTex.GetDimensions(texWidth, texHeight);
  int width = (int)texWidth;
  int height = (int)texHeight;

  int2 pixel = int2(floor(pos.xy));
  float4 src = srcTex.Load(int3(pixel, 0));
  float3 color = src.rgb;
  float3 purple = float3(128.0 / 255.0, 0.0, 128.0 / 255.0);
  float3 green = float3(128.0 / 255.0, 1.0, 128.0 / 255.0);
  float3 cyan = float3(0.0, 128.0 / 255.0, 128.0 / 255.0);
  float3 red = float3(1.0, 128.0 / 255.0, 128.0 / 255.0);

  paint_horizontal_pair(pixel, width, height, 3, purple, green, color);
  paint_horizontal_pair(pixel, width, height, 4, purple, green, color);
  paint_horizontal_pair(pixel, width, height, 5, green, purple, color);
  paint_horizontal_pair(pixel, width, height, 6, green, purple, color);

  paint_vertical_pair(pixel, width, height, 3, cyan, red, color);
  paint_vertical_pair(pixel, width, height, 4, cyan, red, color);
  paint_vertical_pair(pixel, width, height, 5, red, cyan, color);
  paint_vertical_pair(pixel, width, height, 6, red, cyan, color);

  return float4(color, src.a);
}
