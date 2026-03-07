--label:tim2\アニメーション効果
---$track:しきい値
---min=0
---max=255
---step=1
local track_threshold = 10

---$track:ずれ
---min=-500
---max=500
---step=1
local track_offset = 10

---$track:ぼかし
---min=0
---max=500
---step=1
local track_blur = 0

---$track:ｶﾞﾗｽ強度
---min=-1000
---max=1000
---step=0.1
local track_glass_intensity = 100

---$track:ガラス画像
---min=1
---max=1000
---step=1
local GIL = 1

---$check:境界を透過
local Edg = 0

---$color:マップ背景色
local Bcol = 0x0

---$track:パターン
---min=0
---max=10000
---step=1
local PT = 0

---$check:マップ表示
local check0 = false

local Sh = track_threshold
local bkb = track_blur
PT = math.abs(PT or 0)
-- require("T_CrackedGlass_Module")
local T_CrackedGlass_Module = obj.module("tim2")
local Pr = { obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect }
local w, h = obj.getpixel()
obj.effect("ぼかし", "範囲", bkb, "サイズ固定", 1)
obj.copybuffer("cache:CG_ORG", "object")
obj.load("layer", GIL or 1, true)
local wg, hg = obj.getpixel()
local Zm
if w * hg < h * wg then
    Zm = h / hg
else
    Zm = w / wg
end
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw(0, 0, 0, Zm)
obj.copybuffer("object", "tempbuffer")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_CrackedGlass_Module.cracked_glass_cracked_glass(userdata, w, h, Sh, PT, check0, Bcol or 0)
obj.putpixeldata("object", userdata, w, h, "bgra")
if not check0 then
    obj.copybuffer("tempbuffer", "object")
    obj.copybuffer("object", "cache:CG_ORG")
    local T = track_offset
    local CS = track_glass_intensity
    obj.effect(
        "ディスプレイスメントマップ",
        "変形X",
        T,
        "変形Y",
        T,
        "ぼかし",
        0,
        "元のサイズに合わせる",
        1,
        "変形方法",
        "移動変形",
        "マップの種類",
        "*tempbuffer"
    )
    userdata, w, h = obj.getpixeldata("object", "bgra")
    T_CrackedGlass_Module.cracked_glass_add_glass(userdata, w, h, CS, Edg, Sh)
    obj.putpixeldata("object", userdata, w, h, "bgra")
end
obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect = unpack(Pr)