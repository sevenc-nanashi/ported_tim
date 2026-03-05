--label:tim2\T_Color_Module.anm\シャドウ・ハイライト
--track0:黒潰補正,-1000,1000,100
--track1:白飛補正,-1000,1000,100
--track2:範囲,1,100,10,1
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Save_G_Image(userdata, w, h)
obj.effect("ぼかし", "範囲", obj.track2, "サイズ固定", 1)
userdata, w, h = obj.getpixeldata()
T_Color_Module.Shadow_Highlight(userdata, w, h, -obj.track0 / 100, obj.track1 / 100)
obj.putpixeldata(userdata)
