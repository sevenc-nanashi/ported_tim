--label:tim2\T_Filter_Module.anm\ノート用紙T
--track0:しきい値,0,255,128,1
--track1:きめ,0,100,75
--track2:レリーフ,0,500,100
--track3:向き,0,7,3,1
--value@col1:シャドウ/col,0x0
--value@col2:ハイライト/col,0xffffff

require("T_Filter_Module")
local userdata, w, h = obj.getpixeldata()
T_Filter_Module.easybinarization(userdata, w, h, obj.track0)
obj.putpixeldata(userdata)
userdata, w, h = obj.getpixeldata()
T_Filter_Module.GrayColor(userdata, w, h, 128, 128, 128, 255, 255, 255)
obj.putpixeldata(userdata)
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()
obj.load("figure", "四角形", 0xffffff, math.max(w, h))
obj.effect("ノイズ", "周期X", 100, "周期Y", 100, "type", 0, "mode", 1)
obj.effect("領域拡張", "塗りつぶし", 1, "上", 1, "下", 1, "左", 1, "右", 1)
userdata, w, h = obj.getpixeldata()
T_Filter_Module.Emboss(userdata, w, h, 1, 2)
obj.putpixeldata(userdata)
obj.effect("クリッピング", "上", 1, "下", 1, "左", 1, "右", 1)
obj.setoption("blend", 2)
obj.draw(0, 0, 0, 1, 0.5 * (1 - obj.track1 * 0.01))
obj.load("tempbuffer")
obj.setoption("blend", 0)
userdata, w, h = obj.getpixeldata()
T_Filter_Module.Emboss(userdata, w, h, obj.track2 * 0.01, obj.track3)
obj.putpixeldata(userdata)
userdata, w, h = obj.getpixeldata()
local r1, g1, b1 = RGB(col1)
local r2, g2, b2 = RGB(col2)
T_Filter_Module.GrayColor(userdata, w, h, r1, g1, b1, r2, g2, b2)
obj.putpixeldata(userdata)
