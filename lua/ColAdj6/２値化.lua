--label:tim2\T_Color_Module.anm\２値化
--track0:閾値,0,255,128,1
--track1:ｸﾞﾚｰ処理,0,2,1,1
--track2:自動判定,0,6,0,1
--value@col1:明部色/col,0xff0000
--value@col2: 暗部色/col,0x0000ff
--check0:色付け,0;
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.binarization(userdata, w, h, obj.track0, obj.track1, obj.track2, obj.check0, col1, col2)
obj.putpixeldata(userdata)
