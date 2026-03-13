--label:tim2\ぼかし\@T_RotBlur_Module
-- ---$track:中心X
-- ---min=-5000
-- ---max=5000
-- ---step=0.1
-- local track_center_x = 0
--
-- ---$track:中心Y
-- ---min=-5000
-- ---max=5000
-- ---step=0.1
-- local track_center_y = 0
--track0:中心X,-5000,5000,0
--track1:中心Y,-5000,5000,0
local track_center_x = obj.track0
local track_center_y = obj.track1

---$track:ブラー量
---min=0
---max=1000
---step=0.1
local track_blur_amount = 30

---$track:基準位置
---min=-100
---max=100
---step=0.1
local track_base_position = 0

---$check:サイズ保持
local check_keep_size = true

---$track:角度解像度ダウン
---min=0
---max=8
---step=1
local track_angle_resolution_down = 0

---$check:高精度表示
local check_high_quality_preview = true

---$check:高精度出力
local check_high_quality_export = true

--[[pixelshader@rot_blur
---$include "./shaders/rot_blur.hlsl"
]]

local log2 = math.log(2)

local is_enabled = function(value)
    return value == true or value == 1
end

local rotation_blur_iterations = function(width, height, center_x, center_y, blur_rad, resolution_down)
    local max_dx = math.max(math.abs(center_x), math.abs(width - center_x))
    local max_dy = math.max(math.abs(center_y), math.abs(height - center_y))
    local arc_length = math.sqrt(max_dx * max_dx + max_dy * max_dy) * math.abs(blur_rad)
    if arc_length <= 0 or arc_length ~= arc_length or arc_length == math.huge then
        return 2
    end

    local exponent = math.ceil(math.log(arc_length) / log2 - math.abs(resolution_down))
    local iterations = 2 ^ exponent
    if iterations ~= iterations or iterations == math.huge or iterations < 2 then
        return 2
    end
    return math.floor(iterations)
end

local w, h = obj.getpixel()
local r = math.sqrt(w * w + h * h)
if not is_enabled(check_keep_size) then
    local addX, addY = math.ceil((r - w) / 2 + 1), math.ceil((r - h) / 2 + 1)
    obj.effect("領域拡張", "上", addY, "下", addY, "右", addX, "左", addX)
end

w, h = obj.getpixel()
obj.setanchor("track", 0, "line")
local center_x = track_center_x
local center_y = track_center_y
local use_high_quality = (not obj.getinfo("saving") and is_enabled(check_high_quality_preview))
    or (obj.getinfo("saving") and is_enabled(check_high_quality_export))
if w > 0 and h > 0 then
    local blur_rad = track_blur_amount * math.pi / 180
    local base_position = track_base_position * 0.01
    local iterations =
        rotation_blur_iterations(w, h, w * 0.5 + center_x, h * 0.5 + center_y, blur_rad, track_angle_resolution_down)
    local step = use_high_quality and (blur_rad / (iterations - 1)) or (blur_rad / iterations)
    local current = math.floor(iterations / 2)
    local high_quality = use_high_quality and 1 or 0

    while true do
        local half = math.floor(current / 2)
        local angle_pos, angle_neg
        if use_high_quality then
            local center_component = half * step * base_position
            local span = blur_rad / current * 0.25
            angle_pos = center_component + span
            angle_neg = center_component - span
        else
            local delta = half * step
            local base_offset = base_position * delta
            angle_pos = base_offset + delta
            angle_neg = base_offset - delta
        end

        obj.pixelshader("rot_blur", "object", "object", {
            center_x,
            center_y,
            math.sin(angle_pos),
            math.cos(angle_pos),
            math.sin(angle_neg),
            math.cos(angle_neg),
            high_quality,
        })

        if current < 2 then
            break
        end
        current = half
    end
end
