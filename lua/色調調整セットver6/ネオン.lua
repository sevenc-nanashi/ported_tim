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

local C = track_luminance_center / 100 + 0.5
local B = track_luminance_range * 0.01
local S = track_intensity * 0.01
local ar = -S / (B * B)
local br = ar * (-2 * C)
local cr = ar * (C * C - B * B)
obj.effect("ぼかし", "範囲", track_blur, "サイズ固定", 1)
obj.pixelshader("neon", "object", "object", {
    ar,
    br,
    cr,
})
