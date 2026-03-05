--label:tim2\T_Color_Module.anm\２値化RGB
--track0:R閾値,0,255,128,1
--track1:G閾値,0,255,128,1
--track2:B閾値,0,255,128,1
--track3:自動判定,0,6,0,1
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.binarizationRGB(userdata, w, h, obj.track0, obj.track1, obj.track2, obj.track3)
obj.putpixeldata(userdata)
