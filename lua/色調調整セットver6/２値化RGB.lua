--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$select:自動判定
---なし=0
---平均値=1
---中央値=2
---判別分析法=3
---Kittlerらの閾値選定法=4
---微分ヒストグラム法=5
---ラプラシアン・ヒストグラム法=6
local select_automatic_detection = 0

---$track:R閾値
---min=0
---max=255
---step=1
local track_red_threshold = 128

---$track:G閾値
---min=0
---max=255
---step=1
local track_green_threshold = 128

---$track:B閾値
---min=0
---max=255
---step=1
local track_blue_threshold = 128

--hide@track_red_threshold:select_automatic_detection~=0
--hide@track_green_threshold:select_automatic_detection~=0
--hide@track_blue_threshold:select_automatic_detection~=0

--[[pixelshader@color_binarization_rgb
---$include "./shaders/binarization_rgb.hlsl"
]]

local red_threshold = track_red_threshold / 255
local green_threshold = track_green_threshold / 255
local blue_threshold = track_blue_threshold / 255

if select_automatic_detection ~= 0 then
    local color_module = obj.module("tim2")
    local pixel_data, width, height = obj.getpixeldata("object", "bgra")
    local thresholds = color_module.color_binarization_rgb_thresholds(
        pixel_data,
        width,
        height,
        track_red_threshold,
        track_green_threshold,
        track_blue_threshold,
        select_automatic_detection
    )
    red_threshold = thresholds[1] / 255
    green_threshold = thresholds[2] / 255
    blue_threshold = thresholds[3] / 255
end

obj.pixelshader("color_binarization_rgb", "object", "object", {
    red_threshold,
    green_threshold,
    blue_threshold,
})
