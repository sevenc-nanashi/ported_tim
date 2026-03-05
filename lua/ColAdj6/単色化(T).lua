--label:tim2\T_Color_Module.anm\単色化(T)
---$track:R
---min=0
---max=255
---step=0.1
local rename_me_track0 = 150

---$track:G
---min=0
---max=255
---step=0.1
local rename_me_track1 = 0

---$track:B
---min=0
---max=255
---step=0.1
local rename_me_track2 = 0

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Monochromatic(userdata, w, h, rename_me_track0, rename_me_track1, rename_me_track2)
obj.putpixeldata(userdata)
