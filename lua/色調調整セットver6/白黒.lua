--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:R%
---min=-500
---max=500
---step=0.1
local red = 100

---$track:G%
---min=-500
---max=500
---step=0.1
local green = 100

---$track:B%
---min=-500
---max=500
---step=0.1
local blue = 100

---$track:W%
---min=-500
---max=500
---step=0.1
local white = 100

---$track:C%
---min=-500
---max=500
---step=0.1
local cyan = 100

---$track:M%
---min=-500
---max=500
---step=0.1
local magenta = 100

---$track:Y%
---min=-500
---max=500
---step=0.1
local yellow = 100

---$color:色付け
local col = nil

---$track:ガンマ値
---min=1
---max=1000
---step=0.1
local gamma = 100

--[[pixelshader@enh_grayscale
---$include "./shaders/enh_grayscale.hlsl"
]]

local color_r, color_g, color_b = RGB(col or 0xffffff)

obj.pixelshader("enh_grayscale", "object", "object", {
    red * 0.01,
    green * 0.01,
    blue * 0.01,
    (cyan or 100) * 0.01,
    (magenta or 100) * 0.01,
    (yellow or 100) * 0.01,
    white * 0.01,
    100 / gamma,
    col and 1 or 0,
    color_r / 255,
    color_g / 255,
    color_b / 255,
})
