--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:輝度中心
---min=-200
---max=200
---step=0.1
local track_luminance_center = 0

---$track:輝度範囲
---min=1
---max=500
---step=0.1
local track_luminance_range = 10

---$track:強度
---min=0
---max=500
---step=0.1
local track_intensity = 100

---$track:ぼかし
---min=0
---max=500
---step=0.1
local track_blur = 5

--[[pixelshader@neon
---$include "./shaders/neon.hlsl"
]]

local luminance_center = track_luminance_center / 100 + 0.5
local luminance_range = track_luminance_range * 0.01
local intensity = track_intensity * 0.01
local quadratic_coefficient = -intensity / (luminance_range * luminance_range)
local linear_coefficient = quadratic_coefficient * (-2 * luminance_center)
local constant_coefficient = quadratic_coefficient
    * (luminance_center * luminance_center - luminance_range * luminance_range)
obj.effect("ぼかし", "範囲", track_blur, "サイズ固定", 1)
obj.pixelshader("neon", "object", "object", {
    quadratic_coefficient,
    linear_coefficient,
    constant_coefficient,
})
