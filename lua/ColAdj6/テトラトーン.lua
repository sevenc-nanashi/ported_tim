--label:tim2\T_Color_Module.anm\テトラトーン
--track0:飽和点1,0,255,0,1
--track1:中間点1,0,255,85,1
--track2:中間点2,0,255,170,1
--track3:飽和点2,0,255,255,1
--value@col1:シャドウ/col,0x000000
--value@col2:ミッドトーン1/col,0xff0000
--value@col3: ミッドトーン2/col,0xffff00
--value@col4: ハイライト/col,0xffffff
local p = { obj.track0, obj.track1, obj.track2, obj.track3 }
table.sort(p)
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Tetratone(userdata, w, h, col1, col2, col3, col4, unpack(p))
obj.putpixeldata(userdata)
