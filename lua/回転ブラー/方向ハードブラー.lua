--label:tim2\ぼかし\@T_RotBlur_Module
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

local is_enabled = function(value)
    return value == true or value == 1
end

local blur_amount = track_blur_amount
if blur_amount ~= 0 then
    local bump_size = track_bump_size
    local angle_degrees = track_angle
    local roundness = track_roundness * 0.01
    local angle_radians = angle_degrees * math.pi / 180
    local base_position = track_base_position
    local amplitude_base = track_width_random_percent
    local blur_correction_scale = track_blur_correction_scale
    local change_seed = math.abs(math.floor(track_change_seed))
    base_position = 0.01 * math.max(-100, math.min(100, base_position))
    amplitude_base = 1 - 0.01 * math.max(0, math.min(100, amplitude_base))
    if change_seed == 0 then
        change_seed = math.floor(obj.time * obj.framerate)
    end

    local userdata, w, h
    w, h = obj.getpixel()
    if not is_enabled(check_keep_size) then
        local cos, sin = math.cos(angle_radians), math.sin(angle_radians)
        local display_limit_scale = math.max(0, (track_display_limit_scale - 1) / 2)
        local iw, ih = w * display_limit_scale, h * display_limit_scale
        local ds1 = blur_amount * (1 - base_position) / 2
        local ds2 = -blur_amount * (1 + base_position) / 2
        local addX1, addY1 = ds1 * cos, ds1 * sin
        local addX2, addY2 = ds2 * cos, ds2 * sin
        addX1, addX2 = math.max(addX1, addX2), -math.min(addX1, addX2)
        addY1, addY2 = math.max(addY1, addY2), -math.min(addY1, addY2)
        addX1 = (addX1 > iw) and iw or addX1
        addX2 = (addX2 > iw) and iw or addX2
        addY1 = (addY1 > ih) and ih or addY1
        addY2 = (addY2 > ih) and ih or addY2
        addX1, addY1 = math.ceil(math.max(addX1, 1)), math.ceil(math.max(addY1, 1))
        addX2, addY2 = math.ceil(math.max(addX2, 1)), math.ceil(math.max(addY2, 1))
        obj.effect("領域拡張", "上", addY2, "下", addY1, "右", addX1, "左", addX2)
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

    local tim2 = obj.module("tim2")
    userdata, w, h = obj.getpixeldata("object", "bgra")
    local work = obj.getpixeldata("work", "bgra")
    tim2.rotblur_dir_hard_blur(
        userdata,
        work,
        w,
        h,
        blur_amount,
        bump_size,
        angle_radians,
        amplitude_base,
        roundness,
        base_position,
        change_seed
    )
    obj.putpixeldata("object", work, w, h, "bgra")
end
