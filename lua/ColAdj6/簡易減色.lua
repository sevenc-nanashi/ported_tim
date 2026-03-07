--label:tim2\色調整\T_Color_Module.anm
--filter
---$track:減色量
---min=0
---max=7
---step=1
local track_color = 3

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.color_color_reduction(userdata, w, h, track_color)
obj.putpixeldata("object", userdata, w, h, "bgra")
