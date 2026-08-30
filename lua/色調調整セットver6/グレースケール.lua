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
local select_grayscale_method = 1

---$track:ガンマ値
---min=1
---max=1000
---step=0.1
local track_gamma = 100

---$color:明部色
local bright_color = 0xffffff

---$color:暗部色
local dark_color = 0x0

--[[pixelshader@grayscale
---$include "./shaders/grayscale.hlsl"
]]

local bright_red, bright_green, bright_blue = RGB(bright_color or 0xffffff)
local dark_red, dark_green, dark_blue = RGB(dark_color or 0x0)

obj.pixelshader("grayscale", "object", "object", {
    select_grayscale_method,
    100 / track_gamma,
    bright_red / 255,
    bright_green / 255,
    bright_blue / 255,
    dark_red / 255,
    dark_green / 255,
    dark_blue / 255,
})
