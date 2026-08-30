--label:${ROOT_CATEGORY}\アニメーション効果
---$track:間隔ミリ秒
---min=1
---max=10000
---step=0.1
local track_interval_ms = 200

---$track:ズームブラー
---min=0
---max=200
---step=0.1
local track_zoom_blur = 100

---$track:スライドブラー
---min=0
---max=200
---step=0.1
local track_slide_blur = 100

---$track:色ずれ補正
---min=0
---max=200
---step=0.1
local track_color_offset_adjust = 100

---$track:ぼかし量
---min=0
---max=100
---step=0.1
local track_blur_amount = 5

---$track:ぼかし発生率％
---min=0
---max=100
---step=0.1
local track_blur_probability = 20

---$track:色量
---min=0
---max=100
---step=0.1
local track_color_amount = 5

---$track:色発生率％
---min=0
---max=100
---step=0.1
local track_color_probability = 20

---$track:明るさ量
---min=0
---max=100
---step=0.1
local track_light_amount = 20

---$track:明るさ発生率％
---min=0
---max=100
---step=0.1
local track_light_probability = 20

---$track:ズーム量
---min=0
---max=100
---step=0.1
local track_zoom_amount = 20

---$track:ズーム発生率％
---min=0
---max=100
---step=0.1
local track_zoom_probability = 20

---$track:スライド量
---min=0
---max=100
---step=0.1
local track_slide_amount = 10

---$track:スライド発生率％
---min=0
---max=100
---step=0.1
local track_slide_probability = 20

---$check:方向指定
local check_use_fixed_direction = 0

---$track:指定方向（度）
---min=-360
---max=360
---step=0.1
local track_direction_deg = 0

---$select:色ずれタイプ
---赤緑A=0
---赤青A=1
---緑青A=2
---赤緑B=3
---赤青B=4
---緑青B=5
local select_color_offset_type = 0

--group:乱数
---$value:シード
local value_seed = 0

---$check:レイヤー依存なし
local check_layer_independent = 1

--hide@track_direction_deg:check_use_fixed_direction==0

local function clamp_percentage(value)
    if value < 0 then
        return 0
    elseif value > 100 then
        return 100
    end
    return value
end

local calculate_random_value = (function(layer_independent)
    if layer_independent == 0 then
        return function(time, probability, minimum_value, maximum_value, value_seed)
            local interval_time = time * 1000 / track_interval_ms + 3103
            local interval_index, time_fraction = math.modf(interval_time)
            local samples = {}
            for i = 0, 3 do
                local sample_index = interval_index + i - 1
                if probability > obj.rand(0, 100, sample_index, value_seed) then
                    local mix_ratio = obj.rand(0, 100, sample_index + 1000, value_seed) * 0.01
                    samples[i] = minimum_value * mix_ratio + maximum_value * (1 - mix_ratio)
                else
                    samples[i] = 0
                end
            end
            return obj.interpolation(time_fraction, samples[0], samples[1], samples[2], samples[3])
        end
    else
        return function(time, probability, minimum_value, maximum_value, value_seed)
            local interval_time = time * 1000 / track_interval_ms + 3103
            local interval_index, time_fraction = math.modf(interval_time)
            local samples = {}
            for i = 0, 3 do
                local sample_index = interval_index + i
                if probability > obj.rand(0, 100, -sample_index, value_seed) then
                    local mix_ratio = obj.rand(0, 100, -sample_index, value_seed + 100) * 0.01
                    samples[i] = minimum_value * mix_ratio + maximum_value * (1 - mix_ratio)
                else
                    samples[i] = 0
                end
            end
            return obj.interpolation(time_fraction, samples[0], samples[1], samples[2], samples[3])
        end
    end
end)(check_layer_independent or 0)
local blur_amount = clamp_percentage(track_blur_amount)
local blur_probability = clamp_percentage(track_blur_probability)
local color_amount = clamp_percentage(track_color_amount)
local color_probability = clamp_percentage(track_color_probability)
local light_amount = clamp_percentage(track_light_amount)
local light_probability = clamp_percentage(track_light_probability)
local zoom_amount = clamp_percentage(track_zoom_amount)
local zoom_probability = clamp_percentage(track_zoom_probability)
local slide_amount = clamp_percentage(track_slide_amount)
local slide_probability = clamp_percentage(track_slide_probability)

local blur_strength = blur_amount
local hue_shift = 360 * color_amount * 0.01
local brightness_shift = light_amount
local zoom_shift = zoom_amount
local slide_ratio = slide_amount * 0.01
check_use_fixed_direction = check_use_fixed_direction or 0
local direction_radians = (track_direction_deg or 0) * math.pi / 180
select_color_offset_type = select_color_offset_type or 0
local w, h = obj.getpixel()
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.setoption("blend", "alpha_add")
local current_time = obj.time
zoom_shift = zoom_shift * calculate_random_value(current_time, zoom_probability, 0, 1, value_seed)
local slide_x, slide_y
local cos_drad = math.cos(direction_radians)
local sin_drad = math.sin(direction_radians)
if check_use_fixed_direction == 1 then
    local slide_distance = w
        * slide_ratio
        * calculate_random_value(current_time, slide_probability, -1, 1, value_seed + 1000)
    slide_x = slide_distance * cos_drad
    slide_y = slide_distance * sin_drad
else
    slide_x = w * slide_ratio * calculate_random_value(current_time, slide_probability, -1, 1, value_seed + 1000)
    slide_y = h * slide_ratio * calculate_random_value(current_time, slide_probability, -1, 1, value_seed + 2000)
end
local unwrapped_slide_x, unwrapped_slide_y = slide_x, slide_y
slide_x = (slide_x + w * 0.5) % w - w * 0.5
slide_y = (slide_y + h * 0.5) % h - h * 0.5
local zoom_ratio = 1 + zoom_shift * 0.01
local tiled_width = w * zoom_ratio
local tiled_height = h * zoom_ratio
obj.draw(slide_x - tiled_width, slide_y - tiled_height, 0, zoom_ratio, 1, 0, 0, 180)
obj.draw(slide_x, slide_y - tiled_height, 0, zoom_ratio, 1, 180, 0, 0)
obj.draw(slide_x + tiled_width, slide_y - tiled_height, 0, zoom_ratio, 1, 0, 0, 180)
obj.draw(slide_x - tiled_width, slide_y, 0, zoom_ratio, 1, 0, 180, 0)
obj.draw(slide_x, slide_y, 0, zoom_ratio)
obj.draw(slide_x + tiled_width, slide_y, 0, zoom_ratio, 1, 0, 180, 0)
obj.draw(slide_x - tiled_width, slide_y + tiled_height, 0, zoom_ratio, 1, 0, 0, 180)
obj.draw(slide_x, slide_y + tiled_height, 0, zoom_ratio, 1, 180, 0, 0)
obj.draw(slide_x + tiled_width, slide_y + tiled_height, 0, zoom_ratio, 1, 0, 0, 180)
obj.load("tempbuffer")
obj.setoption("blend", 0)
blur_strength = blur_strength * calculate_random_value(current_time, blur_probability, 0, 1, value_seed + 3000)
hue_shift = hue_shift * calculate_random_value(current_time, color_probability, -1, 1, value_seed + 4000)
brightness_shift = brightness_shift * calculate_random_value(current_time, light_probability, 0, 1, value_seed + 5000)
obj.effect("ぼかし", "範囲", blur_strength, "サイズ固定", 1)
obj.effect("色調補正", "明るさ", 100 + brightness_shift, "色相", hue_shift)
obj.effect(
    "放射ブラー",
    "範囲",
    zoom_shift * track_zoom_blur * 0.01,
    "X",
    -zoom_ratio * unwrapped_slide_x,
    "Y",
    -zoom_ratio * unwrapped_slide_y,
    "サイズ固定",
    1
)
local previous_slide_x, previous_slide_y, next_slide_x, next_slide_y
local time_fraction = 0.5 / obj.framerate
if check_use_fixed_direction == 1 then
    local slide_distance = w
        * slide_ratio
        * calculate_random_value(current_time - time_fraction, slide_probability, -1, 1, value_seed + 1000)
    previous_slide_x = slide_distance * cos_drad
    previous_slide_y = slide_distance * sin_drad
    slide_distance = w
        * slide_ratio
        * calculate_random_value(current_time + time_fraction, slide_probability, -1, 1, value_seed + 1000)
    next_slide_x = slide_distance * cos_drad
    next_slide_y = slide_distance * sin_drad
else
    previous_slide_x = w
        * slide_ratio
        * calculate_random_value(current_time - time_fraction, slide_probability, -1, 1, value_seed + 1000)
    next_slide_x = w
        * slide_ratio
        * calculate_random_value(current_time + time_fraction, slide_probability, -1, 1, value_seed + 1000)
    previous_slide_y = h
        * slide_ratio
        * calculate_random_value(current_time - time_fraction, slide_probability, -1, 1, value_seed + 2000)
    next_slide_y = h
        * slide_ratio
        * calculate_random_value(current_time + time_fraction, slide_probability, -1, 1, value_seed + 2000)
end
local slide_delta_x = next_slide_x - previous_slide_x
local slide_delta_y = next_slide_y - previous_slide_y
local slide_distance = math.sqrt(slide_delta_x * slide_delta_x + slide_delta_y * slide_delta_y)
local slide_angle_degrees = math.atan2(-slide_delta_x, slide_delta_y) * 180 / math.pi
slide_distance = slide_distance * track_slide_blur * 0.01
local color_offset_distance = slide_distance * track_color_offset_adjust * 0.0025
obj.effect("方向ブラー", "角度", slide_angle_degrees, "範囲", slide_distance, "サイズ固定", 1)
obj.effect(
    "領域拡張",
    "上",
    color_offset_distance,
    "右",
    color_offset_distance,
    "下",
    color_offset_distance,
    "左",
    color_offset_distance,
    "塗りつぶし",
    1
)
local color_offset_type_names = {
    [0] = "赤緑A",
    [1] = "赤青A",
    [2] = "緑青A",
    [3] = "赤緑B",
    [4] = "赤青B",
    [5] = "緑青B",
}
obj.effect(
    "色ずれ",
    "ずれ幅",
    color_offset_distance,
    "角度",
    slide_angle_degrees,
    "色ずれの種類",
    color_offset_type_names[select_color_offset_type] or "赤緑A"
)
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()
obj.load("tempbuffer")
