--label:tim2\T_Color_Module.anm\単色化(T2)
--track0:U,-500,500,5
--track1:V,-500,500,5
--track2:ガンマ,1,1000,100
--check0:参考表示,0
--value@POL:極座標指定/chk,0
require("T_Color_Module")
local UU = obj.track0 * 0.01
local VV = obj.track1 * 0.01
local GM = obj.track2 * 0.01
local POL2 = POL or 0
if POL2 == 1 then
    VV = math.pi * obj.track1 / 360
    UU, VV = UU * math.cos(VV), UU * math.sin(VV)
end
if obj.check0 then
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
