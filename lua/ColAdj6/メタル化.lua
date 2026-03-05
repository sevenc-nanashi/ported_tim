--label:tim2\T_Color_Module.anm\メタル化
---$track:反転濃度1
---min=0
---max=255
---step=1
local rename_me_track0 = 85

---$track:反転濃度2
---min=0
---max=255
---step=1
local rename_me_track1 = 170

---$track:ｸﾞﾚｰ処理
---min=0
---max=2
---step=1
local rename_me_track2 = 1

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.metal(userdata, w, h, rename_me_track0, rename_me_track1, rename_me_track2)
obj.putpixeldata(userdata)
