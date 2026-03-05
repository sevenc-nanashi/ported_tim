--label:tim2\T_Color_Module.anm\単色化(T)
--track0:R,0,255,150
--track1:G,0,255,0
--track2:B,0,255,0
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Monochromatic(userdata, w, h, obj.track0, obj.track1, obj.track2)
obj.putpixeldata(userdata)
