---
description: "HLSL・DLL間のピクセルの違いについて"
globs: ["**/*.hlsl"]
---

# HLSL・DLL間のピクセルの違いについて

## アルファ値の違い

DLLでの受け渡しに使うputpixeldata/getpixeldataでは、アルファ値がStraight Alphaであるのに対して、
HLSLでのテクスチャはPremultiplied Alphaであるため、透明度の扱いに違いがあります。

これに注意してシェーダー化を行う必要があります。

## 256段階の違い

DLLでの受け渡しに使うputpixeldata/getpixeldataでは、アルファ値が0-255の256段階で表現されるのに対して、HLSLでのテクスチャはfloat4で表現されるため、色の階調の扱いに違いがあります。
これに関しては、シェーダー化において、元コードの255段階の挙動を完全に再現する必要はありません。むしろ、速度・HDR対応において不利になることが多いです。
