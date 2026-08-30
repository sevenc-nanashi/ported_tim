--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:R%
---min=-500
---max=500
---step=0.1
local track_red_percent = 100

---$track:G%
---min=-500
---max=500
---step=0.1
local track_green_percent = 100

---$track:B%
---min=-500
---max=500
---step=0.1
local track_blue_percent = 100

---$track:W%
---min=-500
---max=500
---step=0.1
local track_white_percent = 100

---$track:C%
---min=-500
---max=500
---step=0.1
local track_cyan_percent = 100

---$track:M%
---min=-500
---max=500
---step=0.1
local track_magenta_percent = 100

---$track:Y%
---min=-500
---max=500
---step=0.1
local track_yellow_percent = 100

---$color:色付け
local tint_color = nil

---$track:ガンマ値
---min=1
---max=1000
---step=0.1
local track_gamma = 100

--[[pixelshader@enh_grayscale
---$include "./shaders/enh_grayscale.hlsl"
]]

local tint_red, tint_green, tint_blue = RGB(tint_color or 0xffffff)

obj.pixelshader("enh_grayscale", "object", "object", {
    track_red_percent * 0.01,
    track_green_percent * 0.01,
    track_blue_percent * 0.01,
    (track_cyan_percent or 100) * 0.01,
    (track_magenta_percent or 100) * 0.01,
    (track_yellow_percent or 100) * 0.01,
    track_white_percent * 0.01,
    100 / track_gamma,
    tint_color and 1 or 0,
    tint_red / 255,
    tint_green / 255,
    tint_blue / 255,
})
