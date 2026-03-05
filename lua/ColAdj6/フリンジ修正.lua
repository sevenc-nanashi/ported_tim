--label:tim2\T_Color_Module.anm
---$track:補正法
---min=0
---max=3
---step=1
local track_adjust_method = 1

---$track:α上限
---min=0
---max=255
---step=1
local track_alpha_upper_limit = 255

---$track:α下限
---min=0
---max=255
---step=1
local track_alpha_lower_limit = 0

---$color:背景色
local col = 0xffffff

---$check:処理後α補正
local Af = 1

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.FringeFix(userdata, w, h, col, track_adjust_method, track_alpha_upper_limit, track_alpha_lower_limit, Af or 0)
obj.putpixeldata(userdata)
