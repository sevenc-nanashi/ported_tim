--label:tim2\T_Color_Module.anm\金属質
--track0:飽和点1,0,255,64,1
--track1:飽和点2,0,255,178,1
local p3 = math.floor(obj.track0)
local p1 = math.floor(obj.track1)
p1, p3 = math.max(p1, p3), math.min(p1, p3)
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.TritoneV3(userdata, w, h, 0xffffff, 0xffffff, 0x2e1601, p1, p1, p3, 0)
obj.putpixeldata(userdata)
