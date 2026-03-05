--label:tim2\T_Color_Module.anm
---$track:R閾値
---min=0
---max=255
---step=1
local rename_me_track0 = 128

---$track:G閾値
---min=0
---max=255
---step=1
local rename_me_track1 = 128

---$track:B閾値
---min=0
---max=255
---step=1
local rename_me_track2 = 128

---$track:自動判定
---min=0
---max=6
---step=1
local rename_me_track3 = 0

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.binarizationRGB(userdata, w, h, rename_me_track0, rename_me_track1, rename_me_track2, rename_me_track3)
obj.putpixeldata(userdata)
