--label:tim2\色調整\T_Color_Module.anm
---$select:補正法
---アルファ値の変更=0
---背景色の削除=1
---フリンジの上書き=2
---透明度に応じたフリンジの上書き=3
local track_adjust_method = 1

---$track:α上限
---min=0
---max=255
---step=1
local track_alpha_upper_limit = 255

---$track:α下限
---min=0
---max=255
---step=1
local track_alpha_lower_limit = 0

---$color:色
local col = 0xffffff

---$check:処理後α補正
local Af = 1

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.color_fringe_fix(userdata, w, h, col, track_adjust_method, track_alpha_upper_limit, track_alpha_lower_limit, Af or 0)
obj.putpixeldata("object", userdata, w, h, "bgra")