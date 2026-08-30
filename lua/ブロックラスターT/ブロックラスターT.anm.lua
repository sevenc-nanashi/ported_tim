--label:${ROOT_CATEGORY}\アニメーション効果
---$track:高さ
---min=1
---max=1000
---step=0.1
local track_height = 30

---$track:振幅
---min=-5000
---max=5000
---step=0.1
local track_amplitude = 100

---$track:波長
---min=1
---max=5000
---step=0.1
local track_wavelength = 600

---$track:ﾗﾝﾀﾞﾑ性
---min=-100
---max=100
---step=0.1
local track_randomness = 0

---$check:縦方向
local check_vertical = false

---$track:速度(px/s)
---min=-5000
---max=5000
---step=0.1
local track_speed = 100

---$track:オフセット(px)
---min=-10000
---max=10000
---step=0.1
local track_offset = 0

---$track:振幅単位
---min=0
---max=500
---step=0.1
local track_amplitude_step = 0

---$check:画像もシフト(px)
local check_shift_image = 0

---$track:開始振幅%
---min=0
---max=100
---step=0.1
local track_start_amplitude_percent = 100

---$track:終了振幅%
---min=0
---max=100
---step=0.1
local track_end_amplitude_percent = 100

---$track:シード
---min=0
---max=1000000
---step=1
local track_seed = 0

local amplitude = track_amplitude
if amplitude ~= 0 then
    if check_vertical then
        obj.effect("ローテーション", "90度回転", 1)
    end

    local pi = math.pi
    local sine = math.sin
    local block_height = track_height
    local wavelength = track_wavelength
    local randomness = track_randomness / 100
    local width, height = obj.getpixel()
    track_speed = track_speed or 0
    track_offset = track_offset or 0
    track_amplitude_step = track_amplitude_step or 0
    check_shift_image = check_shift_image or 0
    track_start_amplitude_percent = math.min(100, math.max(0, track_start_amplitude_percent or 100)) / 100
    track_end_amplitude_percent = math.min(100, math.max(0, track_end_amplitude_percent or 100)) / 100
    track_seed = -1 - math.abs(track_seed or 0)
    local scroll_offset = track_speed * obj.time
    local half_width, half_height, half_block_height = width / 2, height / 2, block_height / 2

    if check_shift_image == 1 then
        obj.setoption("drawtarget", "tempbuffer", width, height)
        obj.setoption("blend", "alpha_add2")
        local vertical_shift = scroll_offset % height
        obj.draw(0, vertical_shift)
        obj.draw(0, vertical_shift - height)
        obj.load("tempbuffer")
    end

    local band_offset = scroll_offset + half_block_height + track_offset
    local band_index = math.floor((-half_height - band_offset) / block_height)
    local y1 = band_offset + band_index * block_height

    obj.setoption("drawtarget", "tempbuffer", width + 2 * math.abs(amplitude), height)
    obj.setoption("blend", "alpha_add2")

    while y1 < half_height do
        local y2 = y1 + block_height
        local wave_position = y2 - band_offset
        local x1 = sine(2 * pi * wave_position / wavelength)
        if randomness > 0 then
            local x0 = 0
            local weight_sum = 0
            for i = 1, 4 do
                local harmonic_weight = obj.rand(1, 1000, track_seed, i) / 1000
                local harmonic_phase = obj.rand(1, 1000, track_seed, i + 1000) / 1000
                x0 = x0 + harmonic_weight * sine(2 * i * pi * (wave_position / wavelength + harmonic_phase))
                weight_sum = weight_sum + harmonic_weight
            end
            x0 = x0 / weight_sum
            x1 = (1 - randomness) * x1 + randomness * x0
        elseif randomness < 0 then
            band_index = band_index + 1
            local x0 = obj.rand(-1000, 1000, track_seed, band_index) / 1000
            x1 = (1 + randomness) * x1 - randomness * x0
        end
        x1 = amplitude * x1
        if track_amplitude_step > 0 then
            if x1 > 0 then
                x1 = track_amplitude_step * math.floor(x1 / track_amplitude_step)
            else
                x1 = -track_amplitude_step * math.floor(-x1 / track_amplitude_step)
            end
        end
        x1 = x1
            * (
                track_start_amplitude_percent
                + (track_end_amplitude_percent - track_start_amplitude_percent) * (y1 + half_height) / height
            )
        x1 = x1 - half_width
        local x2 = x1 + width
        y1 = math.max(y1, -half_height)
        y2 = math.min(y2, half_height)
        local v1, v2 = y1 + half_height, y2 + half_height
        obj.drawpoly(x1, y1, 0, x2, y1, 0, x2, y2, 0, x1, y2, 0, 0, v1, width, v1, width, v2, 0, v2)
        y1 = y2
    end
    obj.load("tempbuffer")
    if check_vertical then
        obj.effect("ローテーション", "90度回転", -1)
    end
end
