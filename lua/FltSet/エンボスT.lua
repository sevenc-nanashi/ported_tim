--label:tim2\加工\@T_Filter_Module.anm
---$track:強さ
---min=0
---max=1000
---step=0.1
local track_strength = 100

---$track:向き
---min=0
---max=7
---step=1
local track_direction = 1

local T_Filter_Module = obj.module("tim2")
local St = track_strength * 0.01
local Vec = track_direction

obj.effect("領域拡張", "塗りつぶし", 1, "上", 1, "下", 1, "左", 1, "右", 1)
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Filter_Module.filter_emboss(userdata, w, h, St, Vec)
obj.putpixeldata("object", userdata, w, h, "bgra")
obj.effect("クリッピング", "上", 1, "下", 1, "左", 1, "右", 1)
