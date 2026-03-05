--label:tim2
--track0:変換範囲,0,100,100
--track1:適用度,0,100,100
--track2:逆変換,0,1,0,1

require("T_PolarConversion_Module")
local userdata, w, h = obj.getpixeldata()
local work = obj.getpixeldata("work")
local LUD
if obj.track2 == 0 then
    LUD = T_PolarConversion_Module.PolarConversion(userdata, work, w, h, obj.track0 * 0.01, obj.track1 * 0.01)
else
    LUD = T_PolarConversion_Module.PolarInversion(userdata, work, w, h, obj.track0 * 0.01, obj.track1 * 0.01)
end
obj.putpixeldata(LUD)
