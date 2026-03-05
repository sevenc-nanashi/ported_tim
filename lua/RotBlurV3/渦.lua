--label:tim2\T_RotBlur_Module.anm\渦
--track0:中心X,-5000,5000,0
--track1:中心Y,-5000,5000,0
--track2:渦量,-3000,3600,100
--track3:変化,0,1,0,1
--value@ck:サイズ保持/chk,1

obj.setanchor("track", 0, "line")
local dx = obj.track0
local dy = obj.track1
local sw = obj.track2
local ch = obj.track3
local userdata, w, h
w, h = obj.getpixel()
local r = math.sqrt(w * w + h * h)
if ck == 0 then
    local addX, addY = math.ceil((r - w) / 2 + 1), math.ceil((r - h) / 2 + 1)
    obj.effect("領域拡張", "上", addY, "下", addY, "右", addX, "左", addX)
end
require("T_RotBlur_Module")
userdata, w, h = obj.getpixeldata()
local work = obj.getpixeldata("work")
local LUD = T_RotBlur_Module.Whirlpool(userdata, work, w, h, sw, r / 2, dx, dy, ch)
obj.putpixeldata(LUD)
