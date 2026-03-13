--label:tim2\色調整\@T_Color_Module
--filter
---$track:R閾値
---min=0
---max=255
---step=1
local track_r_threshold = 128

---$track:G閾値
---min=0
---max=255
---step=1
local track_g_threshold = 128

---$track:B閾値
---min=0
---max=255
---step=1
local track_b_threshold = 128

---$select:自動判定
---なし=0
---平均値=1
---中央値=2
---判別分析法=3
---Kittlerらの閾値選定法=4
---微分ヒストグラム法=5
---ラプラシアン・ヒストグラム法=6
local track_auto_detect = 0

--[[pixelshader@color_binarization_rgb
---$include "./shaders/binarization_rgb.hlsl"
]]

local threshold_r = track_r_threshold / 255
local threshold_g = track_g_threshold / 255
local threshold_b = track_b_threshold / 255

if track_auto_detect ~= 0 then
    local T_Color_Module = obj.module("tim2")
    local userdata, w, h = obj.getpixeldata("object", "bgra")
    local thresholds = T_Color_Module.color_binarization_rgb_thresholds(
        userdata,
        w,
        h,
        track_r_threshold,
        track_g_threshold,
        track_b_threshold,
        track_auto_detect
    )
    threshold_r = thresholds[1] / 255
    threshold_g = thresholds[2] / 255
    threshold_b = thresholds[3] / 255
end

obj.pixelshader("color_binarization_rgb", "object", "object", {
    threshold_r,
    threshold_g,
    threshold_b,
})
