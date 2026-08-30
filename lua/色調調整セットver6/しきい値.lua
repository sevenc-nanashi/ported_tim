--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:しきい値1
---min=0
---max=255
---step=0.1
local track_threshold_1 = 0

---$track:しきい値2
---min=0
---max=255
---step=0.1
local track_threshold_2 = 128

-- ---$track:判定法
-- ---min=0
-- ---max=4
-- ---step=1
---$select:判定法
---平均=0
---視覚補正=1
---R=2
---G=3
---B=4
local select_detection_method = 0

---$track:透明度
---min=-100
---max=100
---step=0.1
local track_opacity = 0

---$color:置換色
local replacement_color = 0x0

---$check:範囲を反転
local check_invert_range = false

--[[pixelshader@threshold
---$include "./shaders/threshold.hlsl"
]]

if track_threshold_1 > track_threshold_2 then
    track_threshold_1, track_threshold_2 = track_threshold_2, track_threshold_1
end

local threshold_1 = track_threshold_1 / 255
local threshold_2 = track_threshold_2 / 255
local replacement_red, replacement_green, replacement_blue = RGB(replacement_color)

local red_weight, green_weight, blue_weight = 0, 0, 0
if select_detection_method == 0 then
    red_weight = 0.33
    green_weight = 0.34
    blue_weight = 0.33
elseif select_detection_method == 1 then
    red_weight = 0.298
    green_weight = 0.588
    blue_weight = 0.114
elseif select_detection_method == 2 then
    red_weight = 1.0
elseif select_detection_method == 3 then
    green_weight = 1.0
elseif select_detection_method == 4 then
    blue_weight = 1.0
else
    error("unreachable")
end

local outside_opacity_scale = 1.0
local inside_opacity_scale = 1.0
if track_opacity <= 0 then
    outside_opacity_scale = 1.0 + (track_opacity / 100.0)
else
    inside_opacity_scale = 1.0 - (track_opacity / 100.0)
end

obj.pixelshader("threshold", "object", "object", {
    threshold_1,
    threshold_2,
    red_weight,
    green_weight,
    blue_weight,
    inside_opacity_scale,
    outside_opacity_scale,
    replacement_red / 255,
    replacement_green / 255,
    replacement_blue / 255,
    check_invert_range and 1 or 0,
})
