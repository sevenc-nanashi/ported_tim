--label:tim2\色調整\@T_Color_Module
--filter
---$track:飽和点1
---min=0
---max=255
---step=1
local track_n_1 = 0

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
local track_n_2 = 255

---$color:シャドウ
local col1 = 0x000000

---$color:ミッドトーン1
local col2 = 0xff0000

---$color: ミッドトーン2
local col3 = 0xffff00

---$color: ハイライト
local col4 = 0xffffff

--[[pixelshader@tetratone:
---$include "./shaders/tetratone.hlsl"
]]

local p = { track_n_1, track_midpoint_1, track_midpoint_2, track_n_2 }
table.sort(p)
-- require("T_Color_Module")

-- local T_Color_Module = obj.module("tim2")
-- local userdata, w, h = obj.getpixeldata("object", "bgra")
-- T_Color_Module.color_tetratone(userdata, w, h, col1, col2, col3, col4, unpack(p))
-- obj.putpixeldata("object", userdata, w, h, "bgra")
local col1_r, col1_g, col1_b = RGB(col1)
local col2_r, col2_g, col2_b = RGB(col2)
local col3_r, col3_g, col3_b = RGB(col3)
local col4_r, col4_g, col4_b = RGB(col4)
obj.pixelshader("tetratone", "object", "object", {
    col1_r / 255,
    col1_g / 255,
    col1_b / 255,
    col2_r / 255,
    col2_g / 255,
    col2_b / 255,
    col3_r / 255,
    col3_g / 255,
    col3_b / 255,
    col4_r / 255,
    col4_g / 255,
    col4_b / 255,
    p[1] / 255,
    p[2] / 255,
    p[3] / 255,
    p[4] / 255,
})
