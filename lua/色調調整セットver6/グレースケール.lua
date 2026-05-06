--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
-- ---$track:ｸﾞﾚｰ処理
-- ---min=0
-- ---max=2
-- ---step=1
-- local gray_mode = 1
---$select:グレー処理
---RGB平均=0
---NTSC加重平均法=1
---HDTV法=2
local gray_mode = 1

---$track:ガンマ値
---min=1
---max=1000
---step=0.1
local gamma = 100

---$color:明部色
local bright_color = 0xffffff

---$color:暗部色
local dark_color = 0x0

--[[pixelshader@grayscale
---$include "./shaders/grayscale.hlsl"
]]

local bright_r, bright_g, bright_b = RGB(bright_color or 0xffffff)
local dark_r, dark_g, dark_b = RGB(dark_color or 0x0)

obj.pixelshader("grayscale", "object", "object", {
    gray_mode,
    100 / gamma,
    bright_r / 255,
    bright_g / 255,
    bright_b / 255,
    dark_r / 255,
    dark_g / 255,
    dark_b / 255,
})
