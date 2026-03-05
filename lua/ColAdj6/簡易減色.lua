--label:tim2\T_Color_Module.anm
---$track:減色量
---min=0
---max=7
---step=1
local track_color = 3

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.ColorReduction(userdata, w, h, track_color)
obj.putpixeldata(userdata)
