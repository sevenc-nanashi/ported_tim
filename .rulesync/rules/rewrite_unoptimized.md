---
description: "最適化に関するルール"
globs: ["src/*/unoptimized/*.rs"]
---

# 最適化に関するルール

- unoptimizedのファイルを最適化するときは、元のファイルを残さず、`unoptimized`の一つ上の階層に移動させること。
  （例：`src/color/unoptimized/grayscale.rs` を最適化したら、`src/color/grayscale.rs` に移動させる）
