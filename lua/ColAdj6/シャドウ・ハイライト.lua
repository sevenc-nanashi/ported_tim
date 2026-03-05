--label:tim2\T_Color_Module.anm
---$track:黒潰補正
---min=-1000
---max=1000
---step=0.1
local rename_me_track0 = 100

---$track:白飛補正
---min=-1000
---max=1000
---step=0.1
local rename_me_track1 = 100

---$track:範囲
---min=1
---max=100
---step=1
local rename_me_track2 = 10

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Save_G_Image(userdata, w, h)
obj.effect("ぼかし", "範囲", rename_me_track2, "サイズ固定", 1)
userdata, w, h = obj.getpixeldata()
T_Color_Module.Shadow_Highlight(userdata, w, h, -rename_me_track0 / 100, rename_me_track1 / 100)
obj.putpixeldata(userdata)
