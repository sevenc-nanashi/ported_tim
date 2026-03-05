--label:tim2\カメレオン効果.anm\カメレオン効果(背景)
--track0:中心X,-10000,10000,0,1
--track1:中心Y,-10000,10000,0,1
--track2:幅,0,10000,5000,1
--track3:高さ,0,10000,5000,1
--check0:範囲を表示,0;
--value@col:枠色/col,oxffffff
--value@Lw:枠幅,2
require("T_Familiar_Module")
local userdata, w, h = obj.getpixeldata()
T_Familiar_Module.SetColor(userdata, w, h, obj.track0, obj.track1, obj.track2, obj.track3, obj.check0, col, Lw)
obj.putpixeldata(userdata)
