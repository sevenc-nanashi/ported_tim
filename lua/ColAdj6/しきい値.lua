--label:tim2\T_Color_Module.anm\しきい値
--track0:しきい値1,0,255,0
--track1:しきい値2,0,255,128
--track2:判定法,0,4,0,1
--track3:透明度,-100,100,0
--value@col:置換色/col,0x0
--check0:範囲を反転,0
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Threshold(userdata, w, h, obj.track0, obj.track1, obj.track2, obj.track3, col, obj.check0)
obj.putpixeldata(userdata)
