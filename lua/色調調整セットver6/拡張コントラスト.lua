--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:中心
---min=-255
---max=255
---step=0.1
local track_center = 0

---$track:強度
---min=-200
---max=200
---step=0.1
local track_intensity = 100

---$track:明るさ
---min=-255
---max=255
---step=0.1
local track_brightness = 0

---$track:なめらか
---min=0
---max=100
---step=0.001
local track_smoothness = 50

---$check:カーブ表示
local check_show_curve = false

---$track:カーブサイズ
---min=100
---max=1000
---step=1
local track_curve_size = 260

--hide@track_curve_size:check_show_curve==0

--[[pixelshader@extended_contrast
---$include "./shaders/extended_contrast.hlsl"
]]
--[[pixelshader@extended_contrast_curve
---$include "./shaders/extended_contrast.hlsl"
]]

local shader_parameters = {
    track_center,
    track_intensity / 100,
    track_brightness,
    track_smoothness / 100,
}

if check_show_curve then
    obj.load("figure", "四角形", 0xffffff, math.max(100, track_curve_size or 260))
    obj.pixelshader("extended_contrast_curve", "object", "object", shader_parameters)
else
    obj.pixelshader("extended_contrast", "object", "object", shader_parameters)
end
