--label:tim2\T_Color_Module.anm\フリンジ修正
--track0:補正法,0,3,1,1
--track1:α上限,0,255,255,1
--track2:α下限,0,255,0,1
--value@col:背景色/col,0xffffff
--value@Af:処理後α補正/chk,1
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.FringeFix(userdata, w, h, col, obj.track0, obj.track1, obj.track2, Af or 0)
obj.putpixeldata(userdata)
