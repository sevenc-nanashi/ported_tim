--label:tim2\加工\@T_Filter_Module.anm
---$track:しきい値
---min=0
---max=255
---step=1
local track_threshold = 128

---$track:きめ
---min=0
---max=100
---step=0.1
local track_grain = 75

---$track:レリーフ
---min=0
---max=500
---step=0.1
local track_relief = 100

---$select:向き
---左=0
---左上=1
---上=2
---右上=3
---右=4
---右下=5
---下=6
---左下=7
local direction = 3

---$color:シャドウ
local col1 = 0x0

---$color:ハイライト
local col2 = 0xffffff

local T_Filter_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Filter_Module.filter_easy_binarization(userdata, w, h, track_threshold)
obj.putpixeldata("object", userdata, w, h, "bgra")
userdata, w, h = obj.getpixeldata("object", "bgra")
T_Filter_Module.filter_gray_color(userdata, w, h, 128, 128, 128, 255, 255, 255)
obj.putpixeldata("object", userdata, w, h, "bgra")
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()
obj.load("figure", "四角形", 0xffffff, math.max(w, h))
obj.effect("ノイズ", "周期X", 100, "周期Y", 100, "type", 0, "mode", 1)
obj.effect("領域拡張", "塗りつぶし", 1, "上", 1, "下", 1, "左", 1, "右", 1)
userdata, w, h = obj.getpixeldata("object", "bgra")
T_Filter_Module.filter_emboss(userdata, w, h, 1, 2)
obj.putpixeldata("object", userdata, w, h, "bgra")
obj.effect("クリッピング", "上", 1, "下", 1, "左", 1, "右", 1)
obj.setoption("blend", 2)
obj.draw(0, 0, 0, 1, 0.5 * (1 - track_grain * 0.01))
obj.load("tempbuffer")
obj.setoption("blend", 0)
userdata, w, h = obj.getpixeldata("object", "bgra")
T_Filter_Module.filter_emboss(userdata, w, h, track_relief * 0.01, direction)
obj.putpixeldata("object", userdata, w, h, "bgra")
userdata, w, h = obj.getpixeldata("object", "bgra")
local r1, g1, b1 = RGB(col1)
local r2, g2, b2 = RGB(col2)
T_Filter_Module.filter_gray_color(userdata, w, h, r1, g1, b1, r2, g2, b2)
obj.putpixeldata("object", userdata, w, h, "bgra")
