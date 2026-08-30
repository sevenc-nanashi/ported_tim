--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:変化
---min=0
---max=100
---step=0.1
local track_change = 0

---$track:定数
---min=-1000
---max=1000
---step=0.1
local track_constant = 0

---$track:スケール
---min=-1000
---max=1000
---step=0.1
local track_scale = 100

---$color:指定色1
local reference_color = 0x0

---$color:指定色2
local replacement_color = 0xffffff

---$check:指定色からの距離
local check_use_reference_color_distance = false

--require("T_Color_Module")
local reference_red, reference_green, reference_blue = RGB(reference_color)
local replacement_red, replacement_green, replacement_blue = RGB(replacement_color)
local use_reference_color_distance = check_use_reference_color_distance and 1 or 0

--[[pixelshader@standard_color
---$include "./shaders/standard_color.hlsl"
]]

obj.pixelshader("standard_color", "object", "object", {
    reference_red,
    reference_green,
    reference_blue,
    replacement_red,
    replacement_green,
    replacement_blue,
    track_change * 0.01,
    track_constant,
    track_scale,
    use_reference_color_distance,
})
