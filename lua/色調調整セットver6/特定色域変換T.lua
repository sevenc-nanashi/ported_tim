--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:色相範囲
---min=0.1
---max=360
---step=0.1
local track_hue_range = 100

---$track:彩度範囲
---min=0
---max=255
---step=0.1
local track_saturation_range = 255

---$track:輝度調整
---min=0
---max=500
---step=0.1
local track_luminance_adjust = 100

---$track:境界補正
---min=1
---max=360
---step=0.1
local track_boundary_adjust = 2

---$color:変更前
local source_color = 0x0000ff

---$color:変更後
local target_color = 0xff0000

---$track:彩度調整
---min=0
---max=100
---step=0.1
local track_saturation_adjustment = 100

local saturation_adjustment = track_saturation_adjustment or 100
local source_red, source_green, source_blue = RGB(source_color)
local target_red, target_green, target_blue = RGB(target_color)

--[[pixelshader@change_to_color
---$include "./shaders/change_to_color.hlsl"
]]

obj.pixelshader("change_to_color", "object", "object", {
    source_red,
    source_green,
    source_blue,
    target_red,
    target_green,
    target_blue,
    track_hue_range,
    track_saturation_range,
    saturation_adjustment * 0.01,
    track_luminance_adjust * 0.01,
    track_boundary_adjust,
})
