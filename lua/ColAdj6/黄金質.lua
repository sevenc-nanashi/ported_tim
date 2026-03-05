--label:tim2\T_Color_Module.anm\黄金質
--track0:飽和点1,0,255,0,1
--track1:中心点,0,255,153,1
--track2:飽和点2,0,255,230,1
local p3 = math.floor(obj.track0)
local p2 = math.floor(obj.track1)
local p1 = math.floor(obj.track2)
p1, p3 = math.max(p1, p3), math.min(p1, p3)
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.TritoneV3(userdata, w, h, 0xffffff, 0xfd9501, 0x0c0500, p1, p2, p3, 0)
obj.putpixeldata(userdata)
