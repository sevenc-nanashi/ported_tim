--label:tim2\T_Color_Module.anm\ガンマ補正
--track0:赤,1,1000,100
--track1:緑,1,1000,100
--track2:青,1,1000,100
--track3:ALL,1,1000,100
require("T_Color_Module")
local r, g, b
if obj.track3 == 100 then
    r = 100 / obj.track0
    g = 100 / obj.track1
    b = 100 / obj.track2
else
    r = 100 / obj.track3
    g, b = r, r
end
local userdata, w, h = obj.getpixeldata()
T_Color_Module.GammaCorrection(userdata, w, h, r, g, b)
obj.putpixeldata(userdata)
