--label:tim2\T_Filter_Module.anm\エンボスT
--track0:強さ,0,1000,100
--track1:向き,0,7,1,1

require("T_Filter_Module")
local St = obj.track0 * 0.01
local Vec = obj.track1

obj.effect("領域拡張", "塗りつぶし", 1, "上", 1, "下", 1, "左", 1, "右", 1)
local userdata, w, h = obj.getpixeldata()
T_Filter_Module.Emboss(userdata, w, h, St, Vec)
obj.putpixeldata(userdata)
obj.effect("クリッピング", "上", 1, "下", 1, "左", 1, "右", 1)
