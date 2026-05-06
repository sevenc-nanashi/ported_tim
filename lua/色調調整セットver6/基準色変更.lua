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
local track_count = 0

---$track:スケール
---min=-1000
---max=1000
---step=0.1
local track_scale = 100

---$color:指定色1
local col1 = 0x0

---$color:指定色2
local col2 = 0xffffff

---$check:指定色からの距離
local use_distance_from_standard_color = false

--require("T_Color_Module")
local col1_r, col1_g, col1_b = RGB(col1)
local col2_r, col2_g, col2_b = RGB(col2)
local use_distance = use_distance_from_standard_color and 1 or 0

--[[pixelshader@standard_color
---$include "./shaders/standard_color.hlsl"
]]

obj.pixelshader("standard_color", "object", "object", {
    col1_r,
    col1_g,
    col1_b,
    col2_r,
    col2_g,
    col2_b,
    track_change * 0.01,
    track_count,
    track_scale,
    use_distance,
})
