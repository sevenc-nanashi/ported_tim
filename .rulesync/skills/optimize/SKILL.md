---
name: optimize
description: "Optimize the code for better performance."
targets: ["*"]
---

# optimize

AviUtl1から2の更新点として、スクリプト内でのシェーダー記法の追加があります。
これにより、スクリプト内でシェーダーを直接記述できるようになりました。
これにより、パフォーマンスを向上させることができます。

あるスクリプト`lua/${script}/${effect}.lua`があるとします。
このスクリプト内には以下のようなコードが存在するはずです：

```lua
local tim2 = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
tim2.color_binarization(
    userdata,
    w,
    h,
    track_threshold,
    track_gray_process,
    track_auto_detect,
    colorize,
    col1,
    col2
)
obj.putpixeldata("object", userdata, w, h, "bgra")
```

このような`tim2.${module}_${function}`の呼び出しが存在する場合、`./src/${module}/unoptimized/lib.rs`に関数定義が存在するはずです。
そして、ほとんどの場合、`./src/${module}/unoptimized/${script}.rs`に最適化されていない（シングルスレッド）コードが存在します。
これを元コードとします。

## シェーダーによる高速化

このコードを、スクリプト内にシェーダー記法を使用して書き換えます。
シェーダーは以下のように使います：

```lua
--[[pixelshader@${shaderName}
---$include "./shaders/${shaderName}.hlsl"
]]
```

このように書くと、`./shaders/${shaderName}.hlsl`の内容がスクリプト内に展開されます。
また、シェーダーは以下のように書きます：

```hlsl
struct Constants {
  float param1;
  float param2;
  // ...
};

cbuffer constants : register(b0) { Constants constants; }

Texture2D srcTex : register(t0);
Texture2D srcTex2 : register(t1);
// ...

SamplerState srcSmp : register(s0);

float4 ${shaderName}(float4 pos : SV_Position, float2 uv : TEXCOORD0) : SV_TARGET {
  float4 rgba = srcTex.Sample(srcSmp, uv);

  // ...

  return float4(1.0, 0.5, 0.5, 1.0);
}
```

このシェーダー内で、元コードの処理を行うようにします。
シェーダーは以下のように呼び出します：

```lua
obj.pixelshader(
  "${shaderName}",
  destination_buffer,
  { source_buffer1, source_buffer2, ... },
  {
    param1 = value1,
    param2 = value2,
    ...
  }
)
```

このように書くと、`${shaderName}`という名前のシェーダーが呼び出されます。
シェーダー内で、元コードに相当する処理を行うようにします。
また、もしシェーダーと相性の悪いコードが存在する場合は、スクリプト内でシェーダーと通常のコードを組み合わせて書くこともできます。

```lua
local param1 = 0;
-- 条件分岐
if track_01 == 1 then
  param1 = 0.5;
end

obj.pixelshader(
  "${shaderName}",
  "object",
  { "object" },
  {
    param1,
    value2,
    ...
  }
)
```

## rayonによる最適化

シェーダーでの最適化が難しい場合は、rayonを使用してコードをマルチスレッド化することもできます。
rayonを使用する場合は、`./src/${module}/${script}.rs` に最適化されたコードを記述し、`./src/${module}/lib.rs` にてブリッジの関数を定義します。
ブリッジの関数を定義する場合は、必ず`${module}_`を関数名のプレフィックスとして使用してください。

## その他

また、コンピュートシェーダーも存在します。詳細については <https://docs.aviutl2.jp/lua.md> を参照してください。
