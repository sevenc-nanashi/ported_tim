--label:tim2\ぼかし\@T_RotBlur_Module.anm
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
---max=200
---step=0.1
local track_blur_amount = 20

---$track:凸数
---min=3
---max=500
---step=1
local track_count = 20

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

---$track:表示限界倍率
---min=1
---max=10
---step=0.1
local track_display_limit_scale = 3

local is_enabled = function(value)
    return value == true or value == 1
end

local blur_amount = track_blur_amount * 0.01
if blur_amount ~= 0 then
    obj.setanchor("track", 0, "line")
    local center_x = track_center_x
    local center_y = track_center_y
    local sample_count = track_count
    local base_position = RotBlur_BasePosition or track_base_position
    local amplitude_base = RotBlur_WidthRandomPercent or track_width_random_percent
    local roundness = RotBlur_Roundness or track_roundness
    base_position = 0.01 * math.max(-100, math.min(100, base_position))
    amplitude_base = 1 - 0.01 * math.max(0, math.min(100, amplitude_base))
    roundness = 0.01 * math.max(-100, math.min(100, roundness))
    local change_seed = math.abs(math.floor(track_change_seed))
    local blur_correction_scale = track_blur_correction_scale

    local userdata, w, h
    w, h = obj.getpixel()
    local r = math.sqrt(w * w + h * h)

    if not is_enabled(check_keep_size) and blur_amount > 0 then
        local display_limit_scale = math.max(0, (track_display_limit_scale - 1) / 2)
        local iw, ih = w * display_limit_scale, h * display_limit_scale
        local blur_scale = blur_amount / 2 * (1 + base_position)
        local addX, addY
        if blur_scale < 1 then
            blur_scale = blur_scale / (1 - blur_scale)
            addX, addY = (w / 2 + math.abs(center_x)) * blur_scale + 1, (h / 2 + math.abs(center_y)) * blur_scale + 1
            addX = (addX > iw) and iw or addX
            addY = (addY > ih) and ih or addY
        else
            addX, addY = iw, ih
        end
        addX, addY = math.ceil(addX), math.ceil(addY)
        obj.effect("領域拡張", "上", addY, "下", addY, "右", addX, "左", addX)
    end

    local tim2 = obj.module("tim2")
    userdata, w, h = obj.getpixeldata("object", "bgra")
    if change_seed == 0 then
        change_seed = math.floor(obj.time * obj.framerate)
    end

    if is_enabled(check_blur_correction) then
        tim2.rotblur_rad_blur(
            userdata,
            w,
            h,
            blur_correction_scale * blur_amount * sample_count / 600,
            center_x,
            center_y,
            0
        )
        obj.putpixeldata("object", userdata, w, h, "bgra")
        userdata, w, h = obj.getpixeldata("object", "bgra")
    end

    obj.clearbuffer("cache:work", w, h)
    local work = obj.getpixeldata("cache:work", "bgra")
    tim2.rotblur_rad_hard_blur(
        userdata,
        work,
        w,
        h,
        blur_amount,
        center_x,
        center_y,
        sample_count,
        amplitude_base,
        roundness,
        base_position,
        change_seed
    )
    obj.putpixeldata("object", work, w, h, "bgra")
    RotBlur_BasePosition = nil
    RotBlur_WidthRandomPercent = nil
    RotBlur_Roundness = nil
end
