--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:飽和点1
---min=0
---max=255
---step=1
local track_lower_saturation_point = 0

---$track:中間点1
---min=0
---max=255
---step=1
local track_midpoint_1 = 85

---$track:中間点2
---min=0
---max=255
---step=1
local track_midpoint_2 = 170

---$track:飽和点2
---min=0
---max=255
---step=1
local track_upper_saturation_point = 255

---$color:シャドウ
local shadow_color = 0x000000

---$color:ミッドトーン1
local midtone_1_color = 0xff0000

---$color: ミッドトーン2
local midtone_2_color = 0xffff00

---$color: ハイライト
local highlight_color = 0xffffff

--[[pixelshader@tetratone:
---$include "./shaders/tetratone.hlsl"
]]

local tone_points = { track_lower_saturation_point, track_midpoint_1, track_midpoint_2, track_upper_saturation_point }
table.sort(tone_points)
-- require("T_Color_Module")

-- local T_Color_Module = obj.module("tim2")
-- local userdata, w, h = obj.getpixeldata("object", "bgra")
-- T_Color_Module.color_tetratone(userdata, w, h, col1, col2, col3, col4, unpack(p))
-- obj.putpixeldata("object", userdata, w, h, "bgra")
local shadow_red, shadow_green, shadow_blue = RGB(shadow_color)
local midtone_1_red, midtone_1_green, midtone_1_blue = RGB(midtone_1_color)
local midtone_2_red, midtone_2_green, midtone_2_blue = RGB(midtone_2_color)
local highlight_red, highlight_green, highlight_blue = RGB(highlight_color)
obj.pixelshader("tetratone", "object", "object", {
    shadow_red / 255,
    shadow_green / 255,
    shadow_blue / 255,
    midtone_1_red / 255,
    midtone_1_green / 255,
    midtone_1_blue / 255,
    midtone_2_red / 255,
    midtone_2_green / 255,
    midtone_2_blue / 255,
    highlight_red / 255,
    highlight_green / 255,
    highlight_blue / 255,
    tone_points[1] / 255,
    tone_points[2] / 255,
    tone_points[3] / 255,
    tone_points[4] / 255,
})
