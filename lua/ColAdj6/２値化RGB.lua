--label:tim2\T_Color_Module.anm
---$track:R閾値
---min=0
---max=255
---step=1
local track_r_threshold = 128

---$track:G閾値
---min=0
---max=255
---step=1
local track_g_threshold = 128

---$track:B閾値
---min=0
---max=255
---step=1
local track_b_threshold = 128

---$select:自動判定
---なし=0
---平均値=1
---中央値=2
---判別分析法=3
---Kittlerらの閾値選定法=4
---微分ヒストグラム法=5
---ラプラシアン・ヒストグラム法=6
local track_auto_detect = 0

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.binarization_rgb(userdata, w, h, track_r_threshold, track_g_threshold, track_b_threshold, track_auto_detect)
obj.putpixeldata("object", userdata, w, h, "bgra")