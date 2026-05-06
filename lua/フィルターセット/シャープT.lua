--label:${ROOT_CATEGORY}\加工\@T_Filter_Module
---$track:強さ
---min=0
---max=1000
---step=0.1
local track_strength = 100

---$track:半径
---min=1
---max=100
---step=1
local track_radius = 1

---$select:処理方式
---アンシャープマスク=1
---シャープ=0
local mode = 1

local St = track_strength * 0.01

--[[pixelshader@sharp
---$include "./shaders/sharp.hlsl"
]]
--[[pixelshader@unsharp_mask
---$include "./shaders/unsharp_mask.hlsl"
]]

if mode == 1 then
    obj.copybuffer("cache:unsharp_original", "object")
    obj.effect("ぼかし", "範囲", track_radius, "サイズ固定", 1)
    obj.pixelshader("unsharp_mask", "object", { "cache:unsharp_original", "object" }, { St })
else
    obj.effect("領域拡張", "塗りつぶし", 1, "上", 1, "下", 1, "左", 1, "右", 1)
    obj.pixelshader("sharp", "object", "object", { St })
    obj.effect("クリッピング", "上", 1, "下", 1, "左", 1, "右", 1)
end
