--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
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
local select_matching_method = 1

---$color:抽出色
local extraction_color = 0xff0000

local extraction_red, extraction_green, extraction_blue = RGB(extraction_color)
--[[pixelshader@leave_color
---$include "./shaders/leave_color.hlsl"
]]
obj.pixelshader("leave_color", "object", "object", {
    extraction_red / 255,
    extraction_green / 255,
    extraction_blue / 255,
    track_color_cut_amount / 100,
    track_color_difference_range,
    track_edge,
    select_matching_method,
})
