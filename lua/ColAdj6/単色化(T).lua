--label:tim2\T_Color_Module.anm
---$track:R
---min=0
---max=255
---step=0.1
local track_r = 150

---$track:G
---min=0
---max=255
---step=0.1
local track_g = 0

---$track:B
---min=0
---max=255
---step=0.1
local track_b = 0

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Monochromatic(userdata, w, h, track_r, track_g, track_b)
obj.putpixeldata(userdata)
