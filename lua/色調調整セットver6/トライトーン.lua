--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:飽和点1
---min=0
---max=255
---step=1
local track_lower_saturation_point = 0

---$track:中心点
---min=0
---max=255
---step=1
local track_center = 128

---$track:飽和点2
---min=0
---max=255
---step=1
local track_upper_saturation_point = 255

---$check:ミッドトーン色無視
local check_ignore_midtone = false

---$color:シャドウ
local shadow_color = 0x000000

---$color: ミッドトーン
local midtone_color = 0xb5982c

---$color: ハイライト
local highlight_color = 0xffffff

--hide@midtone_color:check_ignore_midtone==1

--[[pixelshader@tritone
---$include "./shaders/tritone.hlsl"
]]

local tone_points = {
    track_lower_saturation_point,
    track_center,
    track_upper_saturation_point,
}
table.sort(tone_points)

local highlight_red, highlight_green, highlight_blue = RGB(highlight_color)
local midtone_red, midtone_green, midtone_blue = RGB(midtone_color)
local shadow_red, shadow_green, shadow_blue = RGB(shadow_color)
if check_ignore_midtone then
    midtone_red = highlight_red / 2 + shadow_red / 2
    midtone_green = highlight_green / 2 + shadow_green / 2
    midtone_blue = highlight_blue / 2 + shadow_blue / 2
end
obj.pixelshader("tritone", "object", "object", {
    highlight_red / 255,
    highlight_green / 255,
    highlight_blue / 255,
    midtone_red / 255,
    midtone_green / 255,
    midtone_blue / 255,
    shadow_red / 255,
    shadow_green / 255,
    shadow_blue / 255,
    tone_points[3] / 255,
    tone_points[2] / 255,
    tone_points[1] / 255,
})
-- local T_Color_Module = obj.module("tim2")
-- local userdata, w, h = obj.getpixeldata("object", "bgra")
-- T_Color_Module.color_tritone_v3(userdata, w, h, col1, col2, col3, p1, p2, p3, egm or 0)
-- obj.putpixeldata("object", userdata, w, h, "bgra")
