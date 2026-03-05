--label:tim2\T_Color_Module.anm\簡易減色
--track0:減色量,0,7,3,1
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.ColorReduction(userdata, w, h, obj.track0)
obj.putpixeldata(userdata)
