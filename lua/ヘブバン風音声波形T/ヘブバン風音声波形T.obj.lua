--label:${ROOT_CATEGORY}\カスタムオブジェクト
---$track:外円サイズ
---min=0
---max=5000
---step=1
local track_size = 300

---$track:分割量
---min=2
---max=400
---step=1
local track_split_amount = 120

---$track:最大長%
---min=0
---max=2000
---step=0.1
local track_max_percent = 30

---$track:音量上限
---min=1
---max=100000
---step=1
local track_upper_limit = 30000

---$color:波形色1
local wave_color_1 = 0xc19ec1

---$color:波形色2
local wave_color_2 = 0x40acac

---$color:波形色3
local wave_color_3 = 0x5a72ec

---$color:円色1
local circle_color_1 = 0x40acac

---$color:円色2
local circle_color_2 = 0xed7aff

---$track:音量下限
---min=0
---max=100000
---step=1
local track_lower_limit = 0

---$track:境界補正
---min=0
---max=20
---step=1
local track_boundary_adjust = 2

---$value:サイズ配列
local size_array = { 4, 3, 4, 4, 1 }

---$value:個数配列
local count_array = { 100, 230, 180 }

---$value:速度配列
local speed_array = { 2, 2.8, 0 }

--group:オリジナル背景設定
---$check:オリジナル背景を使用
local check_original_background = false

---$track:波形透明度％
---min=0
---max=100
---step=0.1
local track_wave_opacity_percent = 35

---$track:時間オフセット
---min=-10000
---max=10000
---step=1
local track_time_offset = 1000
--group:

---$value:PI
local override_params = nil

---$check:波形反転
local check_reverse_waveform = false

--hide@track_wave_opacity_percent:check_original_background==0
--hide@track_time_offset:check_original_background==0

local floor = math.floor
local abs = math.abs
local max = math.max
local min = math.min
local sin = math.sin
local cos = math.cos
local pi = math.pi
local exp = math.exp
override_params = override_params or {}
local params = override_params
if override_params[1] == "蒼井" then
    override_params = {}
end
local reverse_waveform = override_params[0] == nil and check_reverse_waveform or override_params[0]
local base_size = math.floor(override_params[1] or track_size)
local split_count = floor(override_params[2] or track_split_amount)
local max_wave_length = (override_params[3] or track_max_percent) * base_size / 100
local upper_limit = floor(override_params[4] or track_upper_limit)
local lower_limit = floor(track_lower_limit or 0)
local wave_color_1_value = wave_color_1 or 0xc19ec1
local wave_color_2_value = wave_color_2 or 0x40acac
local wave_color_3_value = wave_color_3 or 0x5a72ec
local circle_color_1_value = circle_color_1 or 0x40acac
local circle_color_2_value = circle_color_2 or 0xed7aff
local boundary_adjust = track_boundary_adjust or 2
local inner_circle_dot_size, middle_circle_dot_size, outer_circle_dot_size, wave_dot_size, wave_bar_width =
    unpack(size_array or { 4, 3, 4, 4, 1 })
local inner_circle_count, middle_circle_count, outer_circle_count = unpack(count_array or { 100, 230, 180 })
local inner_circle_phase, outer_circle_phase, wave_phase = unpack(speed_array or { 2, 2.8, 0 })
local use_original_background = check_original_background
local wave_opacity = (track_wave_opacity_percent or 35) / 100
local time_offset = (track_time_offset or 1000) + obj.time
override_params = nil
wave_color_1 = nil
wave_color_2 = nil
wave_color_3 = nil
circle_color_1 = nil
circle_color_2 = nil
track_lower_limit = nil
track_boundary_adjust = nil
size_array = nil
count_array = nil
speed_array = nil
check_original_background = nil
track_wave_opacity_percent = nil
track_time_offset = nil
check_reverse_waveform = nil
local size_scale = base_size / 300
local dt = -obj.time / 180
inner_circle_dot_size = (inner_circle_dot_size or 4) * size_scale
inner_circle_dot_size = max(inner_circle_dot_size, 1)
middle_circle_dot_size = (middle_circle_dot_size or 1) * size_scale
middle_circle_dot_size = max(middle_circle_dot_size, 1)
outer_circle_dot_size = (outer_circle_dot_size or 4) * size_scale
outer_circle_dot_size = max(outer_circle_dot_size, 1)
wave_dot_size = (wave_dot_size or 3) * size_scale
wave_dot_size = max(wave_dot_size, 1)
wave_bar_width = (wave_bar_width or 4) * size_scale
wave_bar_width = max(wave_bar_width, 1)
inner_circle_count = inner_circle_count or 100
middle_circle_count = middle_circle_count or 230
outer_circle_count = outer_circle_count or 180
inner_circle_phase = (inner_circle_phase or 2) * dt
outer_circle_phase = (outer_circle_phase or 2.8) * dt
wave_phase = (wave_phase or 0) * dt
local audio_sample_count, rate, audio_buffer = obj.getaudio(nil, "audiobuffer", "pcm", 5000)
local wave_samples = {}
local sample_count = 3 * split_count
boundary_adjust = min(boundary_adjust, split_count - 1)
for i = 1, sample_count do
    local k = floor(1 + (i - 1) * (audio_sample_count - 1) / (sample_count - 1))
    local l = abs(audio_buffer[k])
    l = max(l, lower_limit)
    l = min(l, upper_limit)
    wave_samples[i] = l * max_wave_length / upper_limit
end
if reverse_waveform then
    for i = 1, sample_count / 2 do
        wave_samples[i], wave_samples[sample_count - i + 1] = wave_samples[sample_count - i + 1], wave_samples[i]
    end
end
if boundary_adjust > 0 then
    for k = 0, 2 do
        local k_sp_n = k * split_count + 1
        local m = (wave_samples[k_sp_n + split_count - 1] + wave_samples[k_sp_n]) / 2
        wave_samples[k_sp_n] = m
        for i = 1, boundary_adjust - 1 do
            wave_samples[k_sp_n + i] = (wave_samples[k_sp_n + i] * i + m * (boundary_adjust - i)) / boundary_adjust
            wave_samples[k_sp_n + split_count - i] = (
                wave_samples[k_sp_n + split_count - i] * i + m * (boundary_adjust - i)
            ) / boundary_adjust
        end
    end
end
local w = base_size + max_wave_length + wave_dot_size
if use_original_background then
    w = max(w, base_size * 678 / 300)
end
w = 2 * floor(w / 2) + 10
local h = w
w = w + abs(obj.screen_w - w) % 2
h = h + abs(obj.screen_h - h) % 2
if use_original_background then
    obj.setoption("drawtarget", "tempbuffer")
    obj.load("figure", "四角形", 0x00001e, 1)
    obj.effect("リサイズ", "ドット数でサイズ指定", 1, "X", w, "Y", h)
    obj.copybuffer("tempbuffer", "object")
    obj.load("figure", "円", 0x508787, base_size * 1.2)
    obj.effect("ぼかし", "範囲", base_size / 3 * 1.2)
    obj.draw()

    obj.load("figure", "円", 0x4a6074, 36 * size_scale)
    for k = 1, 5 do
        local r = size_scale * (150 + 36 * k)
        local d_s = (k + 3) / (12 * k + 50)
        local n = 2 * pi / d_s
        local bai = (k + 4) / 18
        for i = 0, n do
            local s_bai = bai * (n - i) / n
            local ss = i * d_s - time_offset * exp((0.205 * (k - 1)) ^ 3) / 35
            local x = r * cos(ss)
            local y = r * sin(ss)
            obj.draw(x, y, 0, s_bai, 0.5)
        end
    end
    if wave_opacity > 0 then
        obj.copybuffer("cache:wave", "tempbuffer")
    end
else
    obj.setoption("drawtarget", "tempbuffer", w, h)
end
local make_circle = function(color, circle_size, count, phase, radius)
    obj.load("figure", "円", color, circle_size * 2)
    for i = 0, count - 1 do
        local s = (i / count * 2 + phase) * pi
        obj.draw(radius * cos(s), radius * sin(s), 0, 0.5)
    end
end
make_circle(circle_color_1_value, inner_circle_dot_size, inner_circle_count, inner_circle_phase, base_size / 4)
make_circle(circle_color_1_value, middle_circle_dot_size, middle_circle_count, inner_circle_phase, base_size / 2 * 0.95)
make_circle(circle_color_2_value, outer_circle_dot_size, outer_circle_count, outer_circle_phase, base_size / 2)
local make_wave = function(color, band_index, radius)
    local nn1 = floor((band_index - 1) * audio_sample_count / 3 + 1) -- N>2
    local nn2 = floor(band_index * audio_sample_count / 3)
    local dd = (band_index - 1) / 3
    local dt = (band_index - 1) * split_count + 1
    obj.load("figure", "円", color, wave_dot_size * 2)
    for i = 0, split_count - 1 do
        local l2 = wave_samples[i + dt] / 2
        local s = ((i + dd) / split_count * 2 + wave_phase) * pi
        obj.draw((radius - l2) * cos(s), (radius - l2) * sin(s), 0, 0.5)
        obj.draw((radius + l2) * cos(s), (radius + l2) * sin(s), 0, 0.5)
    end
    for i = 0, split_count - 1 do
        local l = wave_samples[i + dt]
        local s = ((i + dd) / split_count * 2 + wave_phase) * pi
        local d = (i + dd) / split_count * 360 + 90 + wave_phase * 180
        obj.load("figure", "四角形", color, 1)
        obj.effect("リサイズ", "ドット数でサイズ指定", 1, "X", wave_bar_width, "Y", l)
        obj.draw(radius * cos(s), radius * sin(s), 0, 1, 1, 0, 0, d)
    end
end
make_wave(wave_color_1_value, 1, base_size * 5 / 16)
make_wave(wave_color_2_value, 2, base_size * 6 / 16)
make_wave(wave_color_3_value, 3, base_size * 7 / 16)
if use_original_background and wave_opacity > 0 then
    obj.copybuffer("object", "cache:wave")
    obj.draw(0, 0, 0, 1, wave_opacity)
end
if params[1] == "蒼井" then
    local lw = params[3] or base_size / 10
    local sf = { params[2] or "", lw, params[4] or 3, params[5] or 0xffffff, params[6] or 0x0 }
    local txt1 = "前は・・・だれもまもれなかった・・・"
    local txt2 = "こんどはまもれましたか・・・？"
    local t = 3 * floor(6 * (obj.time - 2))
    obj.setfont(unpack(sf))
    obj.load("text", txt1)
    local w0 = obj.getpixel()
    txt1 = txt1:sub(1, max(t, 0))
    txt2 = txt2:sub(1, max(t - 54, 0))
    local w
    if txt1 ~= "" then
        obj.setfont(unpack(sf))
        obj.load("text", txt1)
        w = obj.getpixel()
        obj.draw(-w0 / 2 + w / 2, -lw / 2 * 1.2)
        if txt2 ~= "" then
            obj.setfont(unpack(sf))
            obj.load("text", txt2)
            w = obj.getpixel()
            obj.draw(-w0 / 2 + w / 2, lw / 2 * 1.2)
        end
    end
end
obj.copybuffer("object", "tempbuffer")
