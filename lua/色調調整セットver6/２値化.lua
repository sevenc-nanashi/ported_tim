--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:閾値
---min=0
---max=255
---step=1
local track_threshold = 128

-- ---$track:ｸﾞﾚｰ処理
-- ---min=0
-- ---max=2
-- ---step=1
---$select:グレー処理
---RGB平均=0
---NTSC加重平均法=1
---HDTV法=2
local select_grayscale_method = 1

-- ---$track:自動判定
-- ---min=0
-- ---max=6
-- ---step=1
---$select:自動判定
---なし=0
---平均値=1
---中央値=2
---判別分析法=3
---Kittlerらの閾値選定法=4
---微分ヒストグラム法=5
---ラプラシアン・ヒストグラム法=6
local select_automatic_detection = 0

--group:色変更
---$check:色付け
local check_colorize = false
---$color:明部色
local bright_custom_color = 0xff0000
---$color:暗部色
local dark_custom_color = 0x0000ff

--hide@track_threshold:select_automatic_detection~=0
--hide@bright_custom_color:check_colorize==0
--hide@dark_custom_color:check_colorize==0

--[[pixelshader@color_binarization
---$include "./shaders/binarization.hlsl"
]]

local threshold = track_threshold / 255
if select_automatic_detection ~= 0 then
    local color_module = obj.module("tim2")
    local pixel_data, width, height = obj.getpixeldata("object", "bgra")
    threshold = color_module.color_binarization_threshold(
        pixel_data,
        width,
        height,
        track_threshold,
        select_grayscale_method,
        select_automatic_detection
    ) / 255
end

local bright_color = check_colorize and bright_custom_color or 0xffffff
local dark_color = check_colorize and dark_custom_color or 0x000000
local bright_red, bright_green, bright_blue = RGB(bright_color)
local dark_red, dark_green, dark_blue = RGB(dark_color)

obj.pixelshader("color_binarization", "object", "object", {
    threshold,
    select_grayscale_method,
    bright_red / 255,
    bright_green / 255,
    bright_blue / 255,
    dark_red / 255,
    dark_green / 255,
    dark_blue / 255,
})
