--label:tim2\T_Color_Module.anm\サイクルビットシフト
--track0:R8bit,-100,100,0,1
--track1:G8bit,-100,100,0,1
--track2:B8bit,-100,100,0,1
--track3:24bit,-100,100,0,1
--check0:24ビットでシフト,0
require("T_Color_Module")
local r = math.floor(obj.track0)
local g = math.floor(obj.track1)
local b = math.floor(obj.track2)
if obj.check0 then
    r = math.floor(obj.track3)
end
local userdata, w, h = obj.getpixeldata()
T_Color_Module.CycleBitShift(userdata, w, h, r, g, b, obj.check0)
obj.putpixeldata(userdata)
