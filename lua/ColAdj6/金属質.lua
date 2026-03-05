--label:tim2\T_Color_Module.anm\金属質
---$track:飽和点1
---min=0
---max=255
---step=1
local rename_me_track0 = 64

---$track:飽和点2
---min=0
---max=255
---step=1
local rename_me_track1 = 178

local p3 = math.floor(rename_me_track0)
local p1 = math.floor(rename_me_track1)
p1, p3 = math.max(p1, p3), math.min(p1, p3)
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.TritoneV3(userdata, w, h, 0xffffff, 0xffffff, 0x2e1601, p1, p1, p3, 0)
obj.putpixeldata(userdata)
