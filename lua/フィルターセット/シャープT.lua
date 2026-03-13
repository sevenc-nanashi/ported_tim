--label:tim2\加工\@T_Filter_Module
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

local T_Filter_Module = obj.module("tim2")
local St = track_strength * 0.01

if mode == 1 then
    local userdata, w, h = obj.getpixeldata("object", "bgra")
    T_Filter_Module.filter_set_public_image(userdata, w, h)
    obj.effect("ぼかし", "範囲", track_radius, "サイズ固定", 1)
    userdata, w, h = obj.getpixeldata("object", "bgra")
    T_Filter_Module.filter_unsharp_mask(userdata, w, h, St)
    obj.putpixeldata("object", userdata, w, h, "bgra")
else
    obj.effect("領域拡張", "塗りつぶし", 1, "上", 1, "下", 1, "左", 1, "右", 1)
    local userdata, w, h = obj.getpixeldata("object", "bgra")
    T_Filter_Module.filter_sharp(userdata, w, h, St)
    obj.putpixeldata("object", userdata, w, h, "bgra")
    obj.effect("クリッピング", "上", 1, "下", 1, "左", 1, "右", 1)
end
