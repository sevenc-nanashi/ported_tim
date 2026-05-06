---
description: "HLSL・DLL間の透明度の違いについて"
globs: ["**/*.hlsl"]
---

# HLSL・DLL間の透明度の違いについて

DLLでの受け渡しに使うputpixeldata/getpixeldataでは、アルファ値がStraight Alphaであるのに対して、
HLSLでのテクスチャはPremultiplied Alphaであるため、透明度の扱いに違いがあります。

これに注意してシェーダー化を行う必要があります。
