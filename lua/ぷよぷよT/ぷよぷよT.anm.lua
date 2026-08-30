--label:${ROOT_CATEGORY}\アニメーション効果
--group:基本,true

---$track:枠サイズ
---min=0
---max=500
---step=0.1
local track_frame_size = 50

---$track:変形量
---min=0
---max=500
---step=0.1
local track_deform_amount = 20

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$track:変形速度
---min=0
---max=5000
---step=0.1
local track_deform_speed = 100

--group:波形,false

---$track:波数
---min=1
---max=32
---step=1
local track_wave_count = 4

---$track:波形分割
---min=2
---max=200
---step=1
local track_wave_division = 20

---$track:凹凸ランダム性%
---min=0
---max=100
---step=0.1
local track_roughness_random = 30

---$value:中心＆マスク座標
local center_and_mask_coordinates = { 0, 0, 50, 0 }

--group:マスク,false

---$figure:形状
local mask_figure = "円"

---$color:色
local mask_color = 0xff0000

---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_mask_size = 0

---$track:縦横比%
---min=-100
---max=100
---step=0.1
local track_mask_aspect = 0

---$track:マスク回転
---min=-3600
---max=3600
---step=0.1
local track_mask_rotation = 0

---$track:境界ブラー
---min=0
---max=1000
---step=0.1
local track_mask_blur = 0

--group:マップ,false

---$track:マップサイズ
---min=32
---max=4096
---step=1
local track_map_size = 256

---$track:滑らかさ
---min=0
---max=100
---step=0.1
local track_smoothness = 1

---$track:乱数シード
---min=0
---max=100000
---step=1
local track_seed = 0

---$check:マップ表示
local check_map_display = false

---$check:マスク表示
local check_mask_display = false

--group:

--hide@track_deform_amount:check_map_display==1
--hide@track_smoothness:check_map_display==1
--hide@check_mask_display:check_map_display==1
--hide@mask_color:check_map_display==1
--hide@mask_color:check_mask_display==0

local smooth_interpolate = function(start_value, end_value, progress)
    local start_weight = (2 * progress + 1) * (progress - 1) ^ 2
    return start_weight * start_value + (1 - start_weight) * end_value
end

local expansion_scale = 1 + track_frame_size * 0.01
local deformation_amount = track_deform_amount
local rotation_degrees = track_rotation % 360
local animation_speed = track_deform_speed * 0.01
local wave_count = math.floor(track_wave_count)
local wave_segment_count = math.floor(track_wave_division)
local roughness_randomness = track_roughness_random
local mask_size = track_mask_size
local mask_aspect = track_mask_aspect
local mask_rotation = track_mask_rotation
local mask_blur = track_mask_blur
local map_size = math.floor(track_map_size)
local smoothness = track_smoothness
local seed = math.floor(track_seed)
local show_map = check_map_display
local show_mask = check_mask_display

roughness_randomness = roughness_randomness * 0.01
seed = math.abs(seed)

obj.setanchor("center_and_mask_coordinates", 2)

local width, height = obj.getpixel()
local max_dimension = math.max(width, height)
local expanded_size = max_dimension * expansion_scale

local center_x, center_y =
    center_and_mask_coordinates[1] / max_dimension, center_and_mask_coordinates[2] / max_dimension
local mask_x, mask_y = center_and_mask_coordinates[3], center_and_mask_coordinates[4]

local expand_x = math.floor((expanded_size - width) / 2)
local expand_y = math.floor((expanded_size - height) / 2)
obj.effect("領域拡張", "上", expand_y, "下", expand_y, "右", expand_x, "左", expand_x)
obj.copybuffer("cache:ORI", "object")

local sample_count = wave_count * wave_segment_count
local wave_roughness = {}
local interpolated_roughness = {}
local animation_time = obj.time * animation_speed
local animation_frame = math.floor(animation_time)
local animation_fraction = animation_time - animation_frame
for i = 0, wave_count - 1 do
    local start_roughness = 1
        - roughness_randomness * obj.rand(0, 2000, -(i + seed + 100), 1000 + animation_frame) * 0.001
    local end_roughness = 1
        - roughness_randomness * obj.rand(0, 2000, -(i + seed + 100), 1001 + animation_frame) * 0.001
    wave_roughness[i] = smooth_interpolate(start_roughness, end_roughness, animation_fraction)
end
wave_roughness[wave_count] = wave_roughness[0]
local roughness_index = 0
for i = 0, wave_count - 1 do
    for j = 0, wave_segment_count - 1 do
        interpolated_roughness[roughness_index] = (
            (wave_segment_count - j) * wave_roughness[i] + j * wave_roughness[i + 1]
        ) / wave_segment_count
        roughness_index = roughness_index + 1
    end
end
local displacement_strengths = {}
for i = 0, sample_count - 1 do
    displacement_strengths[i] = (1 + interpolated_roughness[i] * math.sin(i / wave_segment_count * 2 * math.pi)) / 2
end
displacement_strengths[sample_count] = displacement_strengths[0]

obj.load("figure", "四角形", 0xffffff, map_size)
obj.pixeloption("type", "rgb")
center_x, center_y = map_size * (center_x / expansion_scale + 0.5), map_size * (center_y / expansion_scale + 0.5)
local maximum_radius =
    math.sqrt(math.max(center_x, map_size - center_x) ^ 2 + math.max(center_y, map_size - center_y) ^ 2)
for i = 0, map_size - 1 do
    for j = 0, map_size - 1 do
        local x, y = i - center_x, j - center_y
        local angle = math.atan2(y, x)
        local radius = 127.5 * math.sqrt(x * x + y * y) / maximum_radius
        local sample_position = (((angle / math.pi + 1) / 2 - rotation_degrees / 360) % 1) * sample_count
        local sample_index = math.floor(sample_position)
        local sample_fraction = sample_position - sample_index
        if sample_fraction > 0 then
            radius = radius
                * smooth_interpolate(
                    displacement_strengths[sample_index],
                    displacement_strengths[sample_index + 1],
                    sample_fraction
                )
        else
            radius = radius * displacement_strengths[sample_index]
        end
        local red_value = 127.5 - radius * math.cos(angle)
        local green_value = 127.5 - radius * math.sin(angle)
        obj.putpixel(i, j, red_value, green_value, 0, 255)
    end
end
obj.copybuffer("tempbuffer", "object")
if mask_size > 0 then
    local mask_scale = map_size / expansion_scale
    local mask_x, mask_y = mask_x * mask_scale / max_dimension + 0.5, mask_y * mask_scale / max_dimension
    obj.load("figure", mask_figure, RGB(127, 127, 127), mask_size)
    if mask_aspect > 0 then
        obj.effect("リサイズ", "X", 100 - mask_aspect)
    elseif mask_aspect < 0 then
        obj.effect("リサイズ", "Y", 100 + mask_aspect)
    end
    obj.effect("ぼかし", "範囲", mask_blur)
    obj.setoption("drawtarget", "tempbuffer")
    obj.draw(mask_x, mask_y, 0, mask_scale / max_dimension, 1, 0, 0, mask_rotation)
end

if not show_map then
    obj.copybuffer("object", "cache:ORI")
    local displacement_amount = deformation_amount * expansion_scale
    obj.effect(
        "ディスプレイスメントマップ",
        "type",
        0,
        "name",
        "*tempbuffer",
        "元のサイズに合わせる",
        1,
        "param0",
        displacement_amount,
        "param1",
        displacement_amount,
        "ぼかし",
        smoothness
    )
    if show_mask then
        obj.copybuffer("tempbuffer", "object")
        obj.load("figure", mask_figure, mask_color, mask_size)
        if mask_aspect > 0 then
            obj.effect("リサイズ", "X", 100 - mask_aspect)
        elseif mask_aspect < 0 then
            obj.effect("リサイズ", "Y", 100 + mask_aspect)
        end
        obj.effect("ぼかし", "範囲", mask_blur)
        obj.setoption("drawtarget", "tempbuffer")
        obj.draw(mask_x, mask_y, 0, 1, 0.75, 0, 0, mask_rotation)
        obj.copybuffer("object", "tempbuffer")
    end
else
    obj.copybuffer("object", "tempbuffer")
end
