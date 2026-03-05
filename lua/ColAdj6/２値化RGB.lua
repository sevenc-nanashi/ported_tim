--label:tim2\T_Color_Module.anm
---$track:R閾値
---min=0
---max=255
---step=1
local track_r_threshold = 128

---$track:G閾値
---min=0
---max=255
---step=1
local track_g_threshold = 128

---$track:B閾値
---min=0
---max=255
---step=1
local track_b_threshold = 128

---$track:自動判定
---min=0
---max=6
---step=1
local track_auto_detect = 0

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.binarizationRGB(userdata, w, h, track_r_threshold, track_g_threshold, track_b_threshold, track_auto_detect)
obj.putpixeldata(userdata)
