--label:tim2\T_Color_Module.anm\単色化(T2)
---$track:U
---min=-500
---max=500
---step=0.1
local rename_me_track0 = 5

---$track:V
---min=-500
---max=500
---step=0.1
local rename_me_track1 = 5

---$track:ガンマ
---min=1
---max=1000
---step=0.1
local rename_me_track2 = 100

---$check:参考表示
local rename_me_check0 = false

---$check:極座標指定
local POL = 0

require("T_Color_Module")
local UU = rename_me_track0 * 0.01
local VV = rename_me_track1 * 0.01
local GM = rename_me_track2 * 0.01
local POL2 = POL or 0
if POL2 == 1 then
    VV = math.pi * rename_me_track1 / 360
    UU, VV = UU * math.cos(VV), UU * math.sin(VV)
end
if rename_me_check0 then
    obj.effect("リサイズ", "拡大率", 100 / 3)
    obj.copybuffer("cache:ORI", "obj")
    local w, h = obj.getpixel()
    obj.setoption("drawtarget", "tempbuffer", 3 * w, 3 * h)
    for i = -1, 1 do
        for j = -1, 1 do
            obj.copybuffer("obj", "cache:ORI")
            local userdata, w, h = obj.getpixeldata()
            T_Color_Module.Monochromatic2(userdata, w, h, UU + i * 0.1, VV + j * 0.1, GM)
            obj.putpixeldata(userdata)
            obj.draw(w * i, -h * j, 0)
        end
    end
    obj.load("tempbuffer")
else
    local userdata, w, h = obj.getpixeldata()
    T_Color_Module.Monochromatic2(userdata, w, h, UU, VV, GM)
    obj.putpixeldata(userdata)
end
