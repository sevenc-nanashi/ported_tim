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
---max=500
---step=0.1
local track_blur_amount = 20

---$track:凹凸量
---min=1
---max=1000
---step=1
local track_bump_amount = 40

---$check:サイズ保持
local check_keep_size = true

---$track:基準位置
---min=-100
---max=100
---step=0.1
local track_base_position = 0

---$track:幅ランダム[%]
---min=0
---max=100
---step=0.1
local track_width_random_percent = 50

---$track:丸み
---min=-100
---max=100
---step=0.1
local track_roundness = 0

---$check:簡易補正
local check_blur_correction = false

---$track:補正係数[%]
---min=0
---max=500
---step=0.1
local track_blur_correction_scale = 100

---$track:変化固定
---min=0
---max=1000
---step=1
local track_change_seed = 1

--[[pixelshader@rot_blur
---$include "./shaders/rot_blur.hlsl"
]]

--[[pixelshader@rot_hard_blur
---$include "./shaders/rot_hard_blur.hlsl"
]]

local log2 = math.log(2)

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

local blur_amount = track_blur_amount
if blur_amount ~= 0 then
    obj.setanchor("track", 0, "line")
    local center_x = track_center_x
    local center_y = track_center_y
    local bump_amount = track_bump_amount
    local base_position = track_base_position
    local amplitude_base = track_width_random_percent
    local roundness = track_roundness
    base_position = 0.01 * math.max(-100, math.min(100, base_position))
    amplitude_base = 1 - 0.01 * math.max(0, math.min(100, amplitude_base))
    roundness = 0.01 * math.max(-100, math.min(100, roundness))
    local blur_correction_scale = track_blur_correction_scale
    local change_seed = math.abs(math.floor(track_change_seed))

    local w, h = obj.getpixel()
    local r = math.sqrt(w * w + h * h)
    if not check_keep_size then
        local addX, addY = math.ceil((r - w) / 2 + 1), math.ceil((r - h) / 2 + 1)
        obj.effect("領域拡張", "上", addY, "下", addY, "右", addX, "左", addX)
    end

    w, h = obj.getpixel()
    if change_seed == 0 then
        change_seed = math.floor(obj.time * obj.framerate)
    end
    if check_blur_correction and w > 0 and h > 0 then
        local correction_blur_amount = blur_amount * bump_amount / r * blur_correction_scale * 0.015
        local correction_blur_rad = correction_blur_amount * math.pi / 180
        local iterations =
            rotation_blur_iterations(w, h, w * 0.5 + center_x, h * 0.5 + center_y, correction_blur_rad, 1)
        local step = correction_blur_rad / iterations
        local current = math.floor(iterations / 2)

        while true do
            local half = math.floor(current / 2)
            local delta = half * step
            obj.pixelshader("rot_blur", "object", "object", {
                center_x,
                center_y,
                math.sin(delta),
                math.cos(delta),
                -math.sin(delta),
                math.cos(delta),
                0,
            })

            if current < 2 then
                break
            end
            current = half
        end
    end

    if w > 0 and h > 0 then
        obj.pixelshader("rot_hard_blur", "object", "object", {
            blur_amount,
            r / 2,
            center_x,
            center_y,
            bump_amount,
            amplitude_base,
            roundness,
            base_position,
            change_seed,
        })
    end
end
