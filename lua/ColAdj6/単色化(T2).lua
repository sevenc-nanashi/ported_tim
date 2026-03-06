--label:tim2\色調整\T_Color_Module.anm
---$track:U
---min=-500
---max=500
---step=0.1
local track_u = 5

---$track:V
---min=-500
---max=500
---step=0.1
local track_v = 5

---$track:ガンマ
---min=1
---max=1000
---step=0.1
local track_gamma = 100

---$check:参考表示
local check0 = false

---$check:極座標指定
local POL = 0

--require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local UU = track_u * 0.01
local VV = track_v * 0.01
local GM = track_gamma * 0.01
local POL2 = POL or 0
if POL2 == 1 then
    VV = math.pi * track_v / 360
    UU, VV = UU * math.cos(VV), UU * math.sin(VV)
end
if check0 then
    obj.effect("リサイズ", "拡大率", 100 / 3)
    obj.copybuffer("cache:ORI", "object")
    local w, h = obj.getpixel()
    obj.setoption("drawtarget", "tempbuffer", 3 * w, 3 * h)
    for i = -1, 1 do
        for j = -1, 1 do
            obj.copybuffer("object", "cache:ORI")
            local userdata, w, h = obj.getpixeldata("object", "bgra")
            T_Color_Module.monochromatic2(userdata, w, h, UU + i * 0.1, VV + j * 0.1, GM)
            obj.putpixeldata("object", userdata, w, h, "bgra")
            obj.draw(w * i, -h * j, 0)
        end
    end
    obj.load("tempbuffer")
else
    local userdata, w, h = obj.getpixeldata("object", "bgra")
    T_Color_Module.monochromatic2(userdata, w, h, UU, VV, GM)
    obj.putpixeldata("object", userdata, w, h, "bgra")
end