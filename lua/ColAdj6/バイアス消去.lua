--label:tim2\T_Color_Module.anm\バイアス消去
--track0:範囲,0,500,30,1
--track1:補正量,-500,500,100
--track2:ｵﾌｾｯﾄ,-300,300,0
--track3:偏差閾値,0,1000,0
--check0:偏差補正,0;
require("T_Color_Module")
userdata, w, h = obj.getpixeldata()
T_Color_Module.BiasDeletion(userdata, w, h, obj.track0, obj.track1, obj.track2, obj.track3, obj.check0)
obj.putpixeldata(userdata)
