--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 100

---$track:彩度
---min=0
---max=100
---step=0.1
local track_saturation = 70

---$track:ガンマ値
---min=1
---max=1000
---step=0.1
local track_gamma = 120

-- require("T_Color_Module")
local blend_ratio = track_intensity * 0.01
local adjusted_saturation = blend_ratio * track_saturation + (1 - blend_ratio) * 100
local gamma_exponent = blend_ratio * 100 / track_gamma + 1 - blend_ratio
obj.setoption("drawtarget", "tempbuffer", obj.w, obj.h)
obj.copybuffer("tempbuffer", "object")
obj.setoption("blend", "overlay")
obj.effect("単色化")
obj.draw(0, 0, 0, 1, blend_ratio)
obj.load("tempbuffer")
obj.setoption("blend", "none")
obj.effect("色調補正", "彩度", adjusted_saturation)

--[[pixelshader@gamma_correction
---$include "./shaders/gamma_correction.hlsl"
]]

obj.pixelshader("gamma_correction", "object", "object", {
    gamma_exponent,
    gamma_exponent,
    gamma_exponent,
})
