--label:tim2\変形
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
local track_inverse_transform = 0

--[[pixelshader@polar_conversion
---$include "./shaders/polcon.hlsl"
]]

local range = track_range * 0.01
local apply_amount = track_apply_amount * 0.01

local w, h = obj.getpixel()
local diag_half = math.sqrt(w * w + h * h) * 0.5
local half_w = w * 0.5
local half_h = h * 0.5
local radius_x = half_w * range + diag_half * (1.0 - range)
local radius_y = half_h * range + diag_half * (1.0 - range)

obj.pixelshader("polar_conversion", "object", "object", {
    w,
    h,
    range,
    apply_amount,
    track_inverse_transform,
    radius_x,
    radius_y,
})
