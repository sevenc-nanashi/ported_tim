--label:tim2\T_Color_Module.anm
---$track:補正法
---min=0
---max=3
---step=1
local rename_me_track0 = 1

---$track:α上限
---min=0
---max=255
---step=1
local rename_me_track1 = 255

---$track:α下限
---min=0
---max=255
---step=1
local rename_me_track2 = 0

---$color:背景色
local col = 0xffffff

---$check:処理後α補正
local Af = 1

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.FringeFix(userdata, w, h, col, rename_me_track0, rename_me_track1, rename_me_track2, Af or 0)
obj.putpixeldata(userdata)
