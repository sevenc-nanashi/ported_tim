--label:${ROOT_CATEGORY}\変形
---$track:変換範囲
---min=0
---max=100
---step=0.1
local track_range = 100

---$track:適用度
---min=0
---max=100
---step=0.1
local track_apply_amount = 100

---$check:逆変換
local check_inverse_transform = 0

--[[pixelshader@polar_conversion
---$include "./shaders/polcon.hlsl"
]]

local range = track_range * 0.01
local apply_amount = track_apply_amount * 0.01

local width, height = obj.getpixel()
local half_diagonal = math.sqrt(width * width + height * height) * 0.5
local half_width = width * 0.5
local half_height = height * 0.5
local radius_x = half_width * range + half_diagonal * (1.0 - range)
local radius_y = half_height * range + half_diagonal * (1.0 - range)

obj.pixelshader("polar_conversion", "object", "object", {
    width,
    height,
    range,
    apply_amount,
    check_inverse_transform,
    radius_x,
    radius_y,
})
