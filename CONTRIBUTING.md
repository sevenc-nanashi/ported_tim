# 開発メモ

- このプロジェクトは[mise](https://mise.jdx.dev/)を使用してバージョンを管理しています。
- luaのプリプロセッシングには[aulua](https://github.com/karoterra/aviutl2-aulua)、開発環境構築には[aviutl2-cli](https://github.com/sevenc-nanashi/aviutl2-cli)を使用しています。
- `rake download`を行うと`./original`下にティム氏のスクリプトがダウンロードされます。
- [luals](https://github.com/LuaLS/lua-language-server)を使用してluaのコード補完を行っています。
  - `external/lua_aviutl_definitions`にAviUtl2の型定義が入っています。
  - AviUtl1とのスクリプトの差異を直すには、型エラーを潰していくのが手っ取り早いと思います。

手助け：

- 優先度は以下です：
  - 最低限動作する（その過程でトラックバーなどの変数名を改善する）
  - パラメーター定義を改善する
  - シェーダーによる実装に置き換える

> [!WARNING]
> 最終目標はシェーダーでの実装のため、Rustでの並列化はしません。
> ただし、シェーダーでの実装が難しい場合はRustでの並列化を行います。

## デコンパイル

- 乱数の一致は目指しません。

### プロンプト

````md
Port these C code to rust function that takes the same parameter as lua, with single thread.
Tell me when there are undefined variables or functions.
Use proper types, such as using `u32` for colors, `usize` for widths, `u8` for numbers that is within [0, 255], etc. These validations are handled by macros.
Use `unreachable!` for unreachable part, and `anyhow::Result` for errors.
Callee's buffer's pixel structure is BGRA, and the output buffer's pixel structure is also BGRA.
You don't have to:
- Port randomization (if there are). Use `rand` crate instead.
- Port receiving parameters from lua. Just assume the parameters are passed as function arguments.

Callee:
```lua
```

C:
```c
```

````
