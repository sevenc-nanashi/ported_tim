--label:tim2\未分類
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

---$value:ガラス画像
local GIL = 1

---$check:境界を透過
local Edg = 0

---$color:マップ背景色
local Bcol = 0x0

---$value:パターン
local PT = 0

---$check:マップ表示
local check0 = false

local Sh = track_threshold
local bkb = track_blur
PT = math.abs(PT or 0)
require("T_CrackedGlass_Module")
local Pr = { obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect }
local w, h = obj.getpixel()
obj.effect("ぼかし", "範囲", bkb, "サイズ固定", 1)
obj.copybuffer("cache:CG_ORG", "obj")
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
obj.copybuffer("obj", "tmp")
local userdata, w, h = obj.getpixeldata()
T_CrackedGlass_Module.CrackedGlass(userdata, w, h, Sh, PT, check0, Bcol or 0)
obj.putpixeldata(userdata)
if not check0 then
    obj.copybuffer("tmp", "obj")
    obj.copybuffer("obj", "cache:CG_ORG")
    local T = track_offset
    local CS = track_glass_intensity
    obj.effect(
        "ディスプレイスメントマップ",
        "param0",
        T,
        "param1",
        T,
        "ぼかし",
        0,
        "元のサイズに合わせる",
        1,
        "type",
        0,
        "name",
        "*tempbuffer",
        "mode",
        0,
        "calc",
        0
    )
    userdata, w, h = obj.getpixeldata()
    T_CrackedGlass_Module.AddGlass(userdata, w, h, CS, Edg, Sh)
    obj.putpixeldata(userdata)
end
obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect = unpack(Pr)
