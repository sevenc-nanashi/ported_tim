--label:tim2\色調整\@T_Color_Module.anm
--filter
---$track:色抜き量
---min=0
---max=100
---step=0.1
local track_color_cut_amount = 100

---$track:色差範囲
---min=0
---max=500
---step=1
local track_color_difference_range = 50

---$track:エッジ
---min=0
---max=100
---step=0.1
local track_edge = 50

---$select:マッチング法
---RGB=1
---L*a*b*色相=2
---L*a*b*輝度=3
---HSV色相=4
local track_matching_method = 1

---$color:抽出色
local col = 0xff0000

local r, g, b = RGB(col)
-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.color_leave_color(
    userdata,
    w,
    h,
    r,
    g,
    b,
    track_color_cut_amount,
    track_color_difference_range,
    track_edge,
    track_matching_method
)
obj.putpixeldata("object", userdata, w, h, "bgra")
