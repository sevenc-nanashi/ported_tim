--label:tim2\色調整\@T_Color_Module
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
--[[pixelshader@leave_color
---$include "./shaders/leave_color.hlsl"
]]
obj.pixelshader("leave_color", "object", "object", {
    r / 255,
    g / 255,
    b / 255,
    track_color_cut_amount / 100,
    track_color_difference_range,
    track_edge,
    track_matching_method,
})
