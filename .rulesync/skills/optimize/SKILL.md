---
name: optimize
description: "Optimize the code for better performance."
targets: ["*"]
---

# optimize

AviUtl1から2の更新点として、スクリプト内でのシェーダー記法の追加があります。
これにより、スクリプト内でシェーダーを直接記述できるようになりました。
これにより、パフォーマンスを向上させることができます。

まず対象を確認します。

1. `lua/${script}/${effect}.lua` に `obj.module("tim2")` と `getpixeldata` / `putpixeldata` があるか確認します。
2. 対応するブリッジ関数を `./src/${module}/mod.rs` で確認します。
3. 元実装を `./src/${module}/unoptimized/${script}.rs` で確認します。

あるスクリプトには以下のようなコードが存在するはずです：

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

## 基本方針

優先順位は以下です。

1. ピクセル単位の適用処理はシェーダーへ移す
2. シェーダー化できない前処理だけ Rust に残す
3. シェーダー化が難しい場合だけ Rayon で CPU 並列化する

`２値化` や `２値化RGB` のように「閾値計算」と「各ピクセルへの適用」が分離できる場合、閾値計算だけ Rust に残し、適用はシェーダーに移すのを優先します。

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
また、もしシェーダーと相性の悪いコードが存在する場合は、スクリプト内でシェーダーと通常のコードを組み合わせます。

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

### 閾値計算だけ Rust に残すパターン

`自動判定` のようにヒストグラムや近傍参照が必要な処理は Rust に残し、戻り値だけ Lua に渡します。

- 単一閾値:
  - Rust に `./src/${module}/${script}.rs` を追加する
  - `./src/${module}/mod.rs` に `${module}_${effect}_threshold` のようなブリッジを追加する
  - Lua では `threshold = tim2.xxx_threshold(...) / 255` のように受け取ってシェーダーへ渡す
- RGB のような複数閾値:
  - Rust の戻り値は `Vec<i32>` を優先する
  - Lua の添字は 1 始まりなので `thresholds[1]`, `thresholds[2]`, `thresholds[3]` を使う

参考実装:

- `./src/color/binarization.rs`
- `./src/color/binarization_rgb.rs`
- `./lua/色調整セットver6/２値化.lua`
- `./lua/色調整セットver6/２値化RGB.lua`

## rayonによる最適化

シェーダーでの最適化が難しい場合は、rayonを使用してコードをマルチスレッド化することもできます。
rayonを使用する場合は、`./src/${module}/${script}.rs` に最適化されたコードを記述し、`./src/${module}/mod.rs` にてブリッジの関数を定義します。
ブリッジの関数を定義する場合は、必ず`${module}_`を関数名のプレフィックスとして使用してください。

### Rayon の注意点

- `fold` / `reduce` で大きい固定長配列を値で返すと、スタック使用量が増えやすいです
- `[u32; 1021]` や `[f64; 256]` のような集計配列は `Vec` を使ってヒープ側に逃がすことを優先します
- チャンネルごとに独立した計算は `into_par_iter()` で並列化しやすいです

## 不要コードの削除

最適化後に元の `unoptimized` 実装と旧ブリッジが参照されなくなった場合は削除して構いません。

削除対象:

- `./src/${module}/unoptimized/${script}.rs`
- `./src/${module}/unoptimized/mod.rs` の `pub mod ...`
- `./src/${module}/mod.rs` の旧ブリッジ関数

削除前に `rg` で参照が残っていないことを確認します。

## HLSL の注意点

- `pow(x, y)` の `x` が負値になり得る場合、`pow(max(x, 0.0), y)` のようにガードする
- `pow(rgb, 2.2)` のような記述は `error X3571` の原因になることがある
- αは元画像の値を維持することが多いので、明示的に `rgba.a` を返す

## 作業後の確認

1. Lua のフォルダ名は既存の実ディレクトリ名をそのまま使う
2. `cargo fmt` を実行する
3. 対象 Lua に `stylua` を実行する
4. `cargo check` を実行する
5. `TASKLIST.md` の `シェーダー化・最適化` 列を更新する

## その他

また、コンピュートシェーダーも存在します。詳細については <https://docs.aviutl2.jp/lua.md> を参照してください。
