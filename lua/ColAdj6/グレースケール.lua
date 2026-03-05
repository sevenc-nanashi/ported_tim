--label:tim2\T_Color_Module.anm
---$track:ｸﾞﾚｰ処理
---min=0
---max=2
---step=1
local rename_me_track0 = 1

---$track:ガンマ値
---min=1
---max=1000
---step=0.1
local rename_me_track1 = 100

---$color:明部色
local col1 = 0xffffff

---$color:暗部色
local col2 = 0x0

col1 = col1 or 0xffffff
col2 = col2 or 0x0
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.GrayScale(userdata, w, h, rename_me_track0, col1, col2, 100 / rename_me_track1)
obj.putpixeldata(userdata)
