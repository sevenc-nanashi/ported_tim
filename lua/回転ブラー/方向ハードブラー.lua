--label:${ROOT_CATEGORY}\ぼかし\@T_RotBlur_Module
---$track:ブラー量
---min=0
---max=2000
---step=0.1
local track_blur_amount = 100

---$track:凹凸サイズ
---min=1
---max=1000
---step=1
local track_bump_size = 30

---$track:角度
---min=-3600
---max=3600
---step=0.1
local track_angle = 0

---$track:丸み
---min=-100
---max=100
---step=0.1
local track_roundness = 0

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

---$track:表示限界倍率
---min=1
---max=10
---step=0.1
local track_display_limit_scale = 3

--hide@track_blur_correction_scale:check_blur_correction==0
--hide@track_display_limit_scale:check_keep_size==1

--[[pixelshader@dir_hard_blur
---$include "./shaders/dir_hard_blur.hlsl"
]]

local is_enabled = function(value)
    return value == true or value == 1
end

local blur_amount = track_blur_amount
if blur_amount ~= 0 then
    local bump_size = track_bump_size
    local angle_degrees = track_angle
    local roundness = track_roundness * 0.01
    local angle_radians = angle_degrees * math.pi / 180
    local cos_theta = math.cos(angle_radians)
    local sin_theta = math.sin(angle_radians)
    local base_position = track_base_position
    local amplitude_base = track_width_random_percent
    local blur_correction_scale = track_blur_correction_scale
    local change_seed = math.abs(math.floor(track_change_seed))
    base_position = 0.01 * math.max(-100, math.min(100, base_position))
    amplitude_base = 1 - 0.01 * math.max(0, math.min(100, amplitude_base))
    if change_seed == 0 then
        change_seed = math.floor(obj.time * obj.framerate)
    end

    local image_width, image_height = obj.getpixel()
    if not is_enabled(check_keep_size) then
        local display_limit_scale = math.max(0, (track_display_limit_scale - 1) / 2)
        local maximum_expand_x, maximum_expand_y = image_width * display_limit_scale, image_height * display_limit_scale
        local positive_displacement = blur_amount * (1 - base_position) / 2
        local negative_displacement = -blur_amount * (1 + base_position) / 2
        local add_x1, add_y1 = positive_displacement * cos_theta, positive_displacement * sin_theta
        local add_x2, add_y2 = negative_displacement * cos_theta, negative_displacement * sin_theta
        add_x1, add_x2 = math.max(add_x1, add_x2), -math.min(add_x1, add_x2)
        add_y1, add_y2 = math.max(add_y1, add_y2), -math.min(add_y1, add_y2)
        add_x1 = (add_x1 > maximum_expand_x) and maximum_expand_x or add_x1
        add_x2 = (add_x2 > maximum_expand_x) and maximum_expand_x or add_x2
        add_y1 = (add_y1 > maximum_expand_y) and maximum_expand_y or add_y1
        add_y2 = (add_y2 > maximum_expand_y) and maximum_expand_y or add_y2
        add_x1, add_y1 = math.ceil(math.max(add_x1, 1)), math.ceil(math.max(add_y1, 1))
        add_x2, add_y2 = math.ceil(math.max(add_x2, 1)), math.ceil(math.max(add_y2, 1))
        obj.effect("領域拡張", "上", add_y2, "下", add_y1, "右", add_x1, "左", add_x2)
    end
    if is_enabled(check_blur_correction) then
        obj.effect(
            "方向ブラー",
            "範囲",
            blur_correction_scale * 0.01 * blur_amount / bump_size / 2,
            "角度",
            90 + angle_degrees,
            "サイズ固定",
            1
        )
    end

    image_width, image_height = obj.getpixel()
    if image_width > 0 and image_height > 0 then
        obj.pixelshader("dir_hard_blur", "object", "object", {
            blur_amount,
            bump_size,
            cos_theta,
            sin_theta,
            amplitude_base,
            roundness,
            base_position,
            change_seed,
        })
    end
end
