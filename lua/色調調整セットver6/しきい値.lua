--label:tim2\色調整\@T_Color_Module
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
local track_detect_method = 0

---$track:透明度
---min=-100
---max=100
---step=0.1
local track_opacity = 0

---$color:置換色
local col = 0x0

---$check:範囲を反転
local invert_range = false

--[[pixelshader@threshold
---$include "./shaders/threshold.hlsl"
]]

if track_threshold_1 > track_threshold_2 then
    track_threshold_1, track_threshold_2 = track_threshold_2, track_threshold_1
end

local threshold_1 = track_threshold_1 / 255
local threshold_2 = track_threshold_2 / 255
local col_r, col_g, col_b = RGB(col)

local weight_r, weight_g, weight_b = 0, 0, 0
if track_detect_method == 0 then
    weight_r = 0.33
    weight_g = 0.34
    weight_b = 0.33
elseif track_detect_method == 1 then
    weight_r = 0.298
    weight_g = 0.588
    weight_b = 0.114
elseif track_detect_method == 2 then
    weight_r = 1.0
elseif track_detect_method == 3 then
    weight_g = 1.0
elseif track_detect_method == 4 then
    weight_b = 1.0
else
    error("unreachable")
end

local out_scale = 1.0
local in_scale = 1.0
if track_opacity <= 0 then
    out_scale = 1.0 + (track_opacity / 100.0)
else
    in_scale = 1.0 - (track_opacity / 100.0)
end

obj.pixelshader("threshold", "object", "object", {
    threshold_1,
    threshold_2,
    weight_r,
    weight_g,
    weight_b,
    in_scale,
    out_scale,
    col_r / 255,
    col_g / 255,
    col_b / 255,
    invert_range and 1 or 0,
})
