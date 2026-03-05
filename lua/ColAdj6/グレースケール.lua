--label:tim2\T_Color_Module.anm\グレースケール
--track0:ｸﾞﾚｰ処理,0,2,1,1
--track1:ガンマ値,1,1000,100
--value@col1:明部色/col,0xffffff
--value@col2:暗部色/col,0x0
col1 = col1 or 0xffffff
col2 = col2 or 0x0
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.GrayScale(userdata, w, h, obj.track0, col1, col2, 100 / obj.track1)
obj.putpixeldata(userdata)
