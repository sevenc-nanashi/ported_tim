--label:tim2\T_Color_Module.anm
---$track:飽和点1
---min=0
---max=255
---step=1
local track_n_1 = 0

---$track:中間点1
---min=0
---max=255
---step=1
local track_midpoint_1 = 85

---$track:中間点2
---min=0
---max=255
---step=1
local track_midpoint_2 = 170

---$track:飽和点2
---min=0
---max=255
---step=1
local track_n_2 = 255

---$color:シャドウ
local col1 = 0x000000

---$color:ミッドトーン1
local col2 = 0xff0000

---$color: ミッドトーン2
local col3 = 0xffff00

---$color: ハイライト
local col4 = 0xffffff

local p = { track_n_1, track_midpoint_1, track_midpoint_2, track_n_2 }
table.sort(p)
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Tetratone(userdata, w, h, col1, col2, col3, col4, unpack(p))
obj.putpixeldata(userdata)
