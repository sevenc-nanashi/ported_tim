--label:tim2\T_Color_Module.anm\テトラトーン
---$track:飽和点1
---min=0
---max=255
---step=1
local rename_me_track0 = 0

---$track:中間点1
---min=0
---max=255
---step=1
local rename_me_track1 = 85

---$track:中間点2
---min=0
---max=255
---step=1
local rename_me_track2 = 170

---$track:飽和点2
---min=0
---max=255
---step=1
local rename_me_track3 = 255

---$value:シャドウ/col
local col1 = 0x000000

---$value:ミッドトーン1/col
local col2 = 0xff0000

---$value: ミッドトーン2/col
local col3 = 0xffff00

---$value: ハイライト/col
local col4 = 0xffffff

local p = { rename_me_track0, rename_me_track1, rename_me_track2, rename_me_track3 }
table.sort(p)
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Tetratone(userdata, w, h, col1, col2, col3, col4, unpack(p))
obj.putpixeldata(userdata)
