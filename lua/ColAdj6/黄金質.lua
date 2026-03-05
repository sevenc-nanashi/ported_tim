--label:tim2\T_Color_Module.anm
---$track:飽和点1
---min=0
---max=255
---step=1
local rename_me_track0 = 0

---$track:中心点
---min=0
---max=255
---step=1
local rename_me_track1 = 153

---$track:飽和点2
---min=0
---max=255
---step=1
local rename_me_track2 = 230

local p3 = math.floor(rename_me_track0)
local p2 = math.floor(rename_me_track1)
local p1 = math.floor(rename_me_track2)
p1, p3 = math.max(p1, p3), math.min(p1, p3)
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.TritoneV3(userdata, w, h, 0xffffff, 0xfd9501, 0x0c0500, p1, p2, p3, 0)
obj.putpixeldata(userdata)
