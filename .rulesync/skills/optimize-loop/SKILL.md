---
name: optimize-loop
description: "Optimize on your own"
targets: ["*"]
---

# optimize-loop

AviUtl2 MCPを使って、自分自身でコードを最適化する方法を説明します。

まず、AviUtl2 MCPを使い、パラメーターを変えて最適化前の加工結果を保存しておきます。
次に、コードを最適化します（optimize Skillを参考にしてください）。
最後に、最適化後で同じパラメーターで加工して、最適化前と最適化後の結果を比較し、計算式が正しく最適化されているかを確認します。
このプロセスを繰り返すことで、最適化を人に頼らず自分で行うことができます。

## AviUtl2 MCPの使用方法

- オブジェクト名は次のフォーマットに従います：`[スクリプト名]@[ファイル名]`
  - スクリプト名はaulua.yamlの`scripts[*].sources[*].label`に対応します。
  - ファイル名はaulua.yamlの`scripts[*].name`に対応します。
