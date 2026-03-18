--label:tim2\色調整\@T_Color_Module
--filter
---$track:飽和点1
---min=0
---max=255
---step=1
local track_n_1 = 0

---$track:中心点
---min=0
---max=255
---step=1
local track_center = 128

---$track:飽和点2
---min=0
---max=255
---step=1
local track_n_2 = 255

---$check:ミッドトーン色無視
local ignore_midtone = false

---$color:シャドウ
local col3 = 0x000000

---$color: ミッドトーン
local col2 = 0xb5982c

---$color: ハイライト
local col1 = 0xffffff

--[[pixelshader@tritone
---$include "./shaders/tritone.hlsl"
]]

local points = {
    track_n_1,
    track_center,
    track_n_2
}
table.sort(points)

local col1_r, col1_g, col1_b = RGB(col1)
local col2_r, col2_g, col2_b = RGB(col2)
local col3_r, col3_g, col3_b = RGB(col3)
if ignore_midtone then
    col2_r = col1_r / 2 + col3_r / 2
    col2_g = col1_g / 2 + col3_g / 2
    col2_b = col1_b / 2 + col3_b / 2
end
obj.pixelshader("tritone", "object", "object", {
    col1_r / 255,
    col1_g / 255,
    col1_b / 255,
    col2_r / 255,
    col2_g / 255,
    col2_b / 255,
    col3_r / 255,
    col3_g / 255,
    col3_b / 255,
    points[3] / 255,
    points[2] / 255,
    points[1] / 255,
})
-- local T_Color_Module = obj.module("tim2")
-- local userdata, w, h = obj.getpixeldata("object", "bgra")
-- T_Color_Module.color_tritone_v3(userdata, w, h, col1, col2, col3, p1, p2, p3, egm or 0)
-- obj.putpixeldata("object", userdata, w, h, "bgra")
