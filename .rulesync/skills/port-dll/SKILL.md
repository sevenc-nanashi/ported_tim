---
name: port-dll
description: "Port DLL from AviUtl1 to AviUtl2"
targets: ["*"]
---

# port-dll

AviUtl1から2の更新点として、32bit DLLから64bit DLLへの移行があります。
このプロジェクトでは、AviUtl1用のDLLをAviUtl2用のDLLに移植することを目的としています。

## 移植手順

- Ghidra MCPを使用して、AviUtl1用のDLLのコードをCに逆コンパイルします。
  - この時、可能な限りアセンブリを避けてください（トークン数・コンテキストウィンドウの制限のため）。
- RustでAviUtl2用のDLLを再実装します。

## 変更点

AviUtl1では、luaのモジュールとしてDLLでの処理が実装されていました：

```lua
require("T_Filter_Module")

T_Filter_Module.some_function()
```

AviUtl2では、`obj.module("tim2")`のように、モジュールをオブジェクトとして扱う形式に変更されました：

```lua
local tim2 = obj.module("tim2")
tim2.some_function()
```

`obj.module`にて使う関数は以下のように定義します：

```rs
#[aviutl2::module::functions]
impl MyModule {
    fn some_function(&self, args: String) -> aviutl2::anyhow::Result<String> {
        // 処理
    }
}
```

## getpixeldata/putpixeldataの移植

AviUtl1では、以下のように`getpixeldata`や`putpixeldata`を使用して、ピクセルデータを取得・設定していました：

```lua
local userdata, width, height = obj.getpixeldata()
T_Filter_Module.some_function(userdata, width, height)
obj.putpixeldata(userdata, width, height)
```

AviUtl2では、シグネチャが変更されたため、以下のように書き換えます：

```lua
local userdata, width, height = obj.getpixeldata("object", "bgra")
local tim2 = obj.module("tim2")
tim2.filter_some_function(userdata, width, height)
obj.putpixeldata("object", userdata, width, height, "bgra"))
```

また、`getpixeldata("work")`は以下のように書き換えます：

```lua
obj.clearbuffer("cache:work", obj.getpixel())
local userdata, width, height = obj.getpixeldata("cache:work", "bgra")
```

## 命名規則

移植前は`T_${moduleName}_Module.${functionName}`のように命名されていましたが、移植後は、`${moduleName}_${functionName}`のように命名します。
例：`T_Filter_Module.some_function` -> `filter_some_function`

また、移植時は、`src/unoptimized/${moduleName}/${functionName}.rs`のように、モジュールごと・関数ごとにファイルを分割して実装します。
例：`T_Filter_Module.some_function` -> `src/unoptimized/filter/some_function.rs`

## 注意点

- `src/lib.rs`には実装の呼び出しのみを記述し、実装は`src/unoptimized`以下に分割して記述してください。
- 現時点ではとりあえず動くコードを目指すため、シングルスレッドに落としてください。
- 乱数は`rand`クレートを使用してください。
