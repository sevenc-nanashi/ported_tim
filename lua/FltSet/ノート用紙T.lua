--label:tim2\T_Filter_Module.anm\ノート用紙T
---$track:しきい値
---min=0
---max=255
---step=1
local rename_me_track0 = 128

---$track:きめ
---min=0
---max=100
---step=0.1
local rename_me_track1 = 75

---$track:レリーフ
---min=0
---max=500
---step=0.1
local rename_me_track2 = 100

---$track:向き
---min=0
---max=7
---step=1
local rename_me_track3 = 3

---$color:シャドウ
local col1 = 0x0

---$color:ハイライト
local col2 = 0xffffff

require("T_Filter_Module")
local userdata, w, h = obj.getpixeldata()
T_Filter_Module.easybinarization(userdata, w, h, rename_me_track0)
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
obj.draw(0, 0, 0, 1, 0.5 * (1 - rename_me_track1 * 0.01))
obj.load("tempbuffer")
obj.setoption("blend", 0)
userdata, w, h = obj.getpixeldata()
T_Filter_Module.Emboss(userdata, w, h, rename_me_track2 * 0.01, rename_me_track3)
obj.putpixeldata(userdata)
userdata, w, h = obj.getpixeldata()
local r1, g1, b1 = RGB(col1)
local r2, g2, b2 = RGB(col2)
T_Filter_Module.GrayColor(userdata, w, h, r1, g1, b1, r2, g2, b2)
obj.putpixeldata(userdata)
