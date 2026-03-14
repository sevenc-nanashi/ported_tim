--label:tim2\ぼかし\@T_RotBlur_Module
---$track:中心X
---min=-5000
---max=5000
---step=0.1
local track_center_x = 0

---$track:中心Y
---min=-5000
---max=5000
---step=0.1
local track_center_y = 0

--trackgroup@track_center_x,track_center_y:中心

---$track:ブラー量
---min=0
---max=1000
---step=0.1
local track_blur_amount = 20

---$track:基準位置
---min=-100
---max=100
---step=0.1
local track_base_position = 0

---$check:サイズ保持
local check_keep_size = true

---$track:表示限界倍率
---min=1
---max=10
---step=0.1
local track_display_limit_scale = 3

--[[pixelshader@rad_blur
---$include "./shaders/rad_blur.hlsl"
]]

local log2 = math.log(2)

local is_enabled = function(value)
    return value == true or value == 1
end

local next_power_of_two = function(value)
    if value <= 0 or value ~= value or value == math.huge then
        return 1
    end
    return math.floor(2 ^ math.ceil(math.log(value) / log2))
end

obj.setanchor("track_center_x,track_center_y", 0, "line")
local center_x = track_center_x
local center_y = track_center_y
local blur_amount = track_blur_amount
local base_position = 0.01 * track_base_position
blur_amount = math.min(blur_amount, 200 / (1 + base_position) - 0.1)
local expand_right, expand_left, expand_bottom, expand_top = 0, 0, 0, 0
if not is_enabled(check_keep_size) then
    local w0, h0 = obj.getpixel()
    local w2, h2 = w0 / 2, h0 / 2
    local display_limit_scale = math.max(0, (track_display_limit_scale - 1) / 2)
    local iw, ih = w0 * display_limit_scale, h0 * display_limit_scale
    local inner_scale = 1 / (1 - blur_amount * (1 + base_position) / 200)
    local outer_scale = 1 / (1 + blur_amount * (1 - base_position) / 200)
    expand_right = ((w2 > center_x and inner_scale or outer_scale) - 1) * (w2 - center_x)
    expand_left = ((-w2 < center_x and inner_scale or outer_scale) - 1) * (w2 + center_x)
    expand_bottom = ((h2 > center_y and inner_scale or outer_scale) - 1) * (h2 - center_y)
    expand_top = ((-h2 < center_y and inner_scale or outer_scale) - 1) * (h2 + center_y)
    expand_right = (expand_right > iw) and iw or expand_right
    expand_left = (expand_left > iw) and iw or expand_left
    expand_bottom = (expand_bottom > ih) and ih or expand_bottom
    expand_top = (expand_top > ih) and ih or expand_top
    expand_right, expand_bottom = math.ceil(math.max(expand_right, 1)), math.ceil(math.max(expand_bottom, 1))
    expand_left, expand_top = math.ceil(math.max(expand_left, 1)), math.ceil(math.max(expand_top, 1))
    obj.effect("領域拡張", "上", expand_top, "下", expand_bottom, "右", expand_right, "左", expand_left)
end

local w, h = obj.getpixel()
if w > 0 and h > 0 and blur_amount ~= 0 then
    local adjusted_center_x = center_x + (expand_left - expand_right) / 2
    local adjusted_center_y = center_y + (expand_top - expand_bottom) / 2
    local blur_scale = blur_amount / 200
    local inner = 1 - (base_position + 1) * blur_scale
    local outer_scale = 1 + (1 - base_position) * blur_scale
    local sign = 1
    local inner_abs = inner
    if inner < 0 then
        sign = -1
        inner_abs = -inner
    end

    local origin_x = w * 0.5 + adjusted_center_x
    local origin_y = h * 0.5 + adjusted_center_y
    local max_dx = math.max(math.abs(origin_x), math.abs(w - origin_x))
    local max_dy = math.max(math.abs(origin_y), math.abs(h - origin_y))
    local displacement = math.sqrt(max_dx * max_dx + max_dy * max_dy) * math.abs(outer_scale - sign * inner_abs)
    local iterations = math.max(next_power_of_two(displacement), 2)

    while iterations > 1 do
        inner_abs = math.sqrt(inner_abs)
        outer_scale = math.sqrt(outer_scale)
        local scale_sum = inner_abs + outer_scale
        obj.pixelshader("rad_blur", "object", "object", {
            adjusted_center_x,
            adjusted_center_y,
            sign,
            inner_abs,
            outer_scale,
            scale_sum,
        })
        iterations = math.floor(iterations / 2)
    end
end
