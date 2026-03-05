--label:tim2\T_Color_Module.anm\基準色変更
--track0:変化,0,100,0
--track1:定数,-1000,1000,0
--track2:スケール,-1000,1000,100
--value@col1:指定色1/col,0x0
--value@col2:指定色2/col,0xffffff
--check0:指定色からの距離,0
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.StandardColor(userdata, w, h, col1, col2, obj.track0 / 100, obj.track1, obj.track2, obj.check0)
obj.putpixeldata(userdata)
