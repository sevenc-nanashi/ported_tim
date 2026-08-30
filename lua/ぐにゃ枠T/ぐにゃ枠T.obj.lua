--label:${ROOT_CATEGORY}\装飾
local seed_interval_index
---$track:サイズ
---min=0
---max=3000
---step=1
local track_size = 200

---$track:線幅
---min=1
---max=500
---step=1
local track_line_width = 5

---$track:変動量
---min=-500
---max=500
---step=0.1
local track_fluctuation_amount = 10

---$track:変動長
---min=2
---max=5000
---step=1
local track_fluctuation_length = 70

---$color:線色
local param_line_color = 0xffffff

---$figure:形状
local param_figure = "円"

---$track:延長%
---min=-100
---max=500
---step=0.1
local param_extension_percent = 10

---$track:縦横比
---min=-100
---max=100
---step=0.1
local param_aspect_ratio = 0

---$track:点間隔
---min=0
---max=200
---step=1
local param_dot_spacing = 2

---$track:分割精度
---min=1
---max=200
---step=1
local param_subdivision_precision = 10

--group:追加角度
---$track:追加角度::追加角度
---min=-360
---max=360
---step=0.1
local param_additional_angle = 0

---$check:自動方向
local param_auto_direction = 0

--group:重ね描き
---$track:重ね描き回数
---min=1
---max=20
---step=1
local param_overdraw_count = 1

---$check:重ね描き::自動調整
local param_auto_adjust_overdraw = 1
--group:乱数

---$track:シード
---min=0
---max=1000000
---step=1
local param_seed = 0

---$track:変化間隔
---min=0
---max=10000
---step=1
local param_seed_change_interval = 0
--group:

---$value: PI
local param_override = {}

---$check:単一線
local check_single_line = false

--hide@param_aspect_ratio:check_single_line==1

param_override = param_override or {}
local frame_size = math.floor(param_override[1] or track_size)
local line_width = math.floor(param_override[2] or track_line_width)
local fluctuation_amount = (param_override[3] or track_fluctuation_amount)
local fluctuation_length = math.floor(param_override[4] or track_fluctuation_length)
local line_color = param_line_color or 0xffffff
local figure = param_figure or "円"
local extension_ratio = (param_extension_percent or 0) / 100
local aspect_ratio = (param_aspect_ratio or 0) / 100
local dot_spacing = math.floor(param_dot_spacing or 1)
local additional_angle = param_additional_angle or 0
local auto_direction = param_auto_direction == 1
local subdivision_count = math.floor(param_subdivision_precision or 10)
local overdraw_count = math.floor(param_overdraw_count or 1)
local auto_adjust_overdraw = param_auto_adjust_overdraw == 1
local random_seeds = param_seed or 0
local seed_change_interval = param_seed_change_interval or 0
local single_line = param_override[0] == nil and check_single_line or param_override[0]
if dot_spacing == 0 then
    dot_spacing = math.floor(2 * math.sqrt(0.2 * (2 * line_width - 0.2)))
end --円と円の交わりによる窪みが0.2ピクセル以下
dot_spacing = math.max(dot_spacing, 1)
subdivision_count = math.max(subdivision_count, 1)
if auto_adjust_overdraw and line_width < 4 then
    overdraw_count = ({ 5, 3, 2 })[line_width]
end
aspect_ratio = math.max(aspect_ratio, -1)
aspect_ratio = math.min(aspect_ratio, 1)
if string.find(tostring(random_seeds), "table:") then
    local base_seed = random_seeds[1] or 0
    random_seeds[1] = math.abs(math.floor(base_seed)) + 2
    for i = 2, 4 do
        random_seeds[i] = math.abs(math.floor(random_seeds[i] or base_seed)) + 2
    end
else
    random_seeds = math.abs(math.floor(random_seeds or 0)) + 2
    random_seeds = { random_seeds, random_seeds, random_seeds, random_seeds }
end
if seed_change_interval > 0 then
    seed_interval_index = math.floor(obj.time * obj.framerate / seed_change_interval)
    for i = 1, 4 do
        random_seeds[i] = random_seeds[i] + seed_interval_index
    end
end
obj.load("figure", figure, line_color, line_width * 2)
obj.effect("リサイズ", "拡大率", 50 * obj.zoom)
obj.zoom = 1
local draw_points_along_curve = function(
    x0_value,
    y0_value,
    direction_sign,
    center_x,
    center_y,
    sampled_point_count,
    side_length,
    sampled_x,
    sampled_y,
    swap_axes,
    side_index
)
    local next_draw_distance = dot_spacing
    local x0, y0 = x0_value, y0_value
    local x1, y1 = sampled_x[direction_sign], sampled_y[direction_sign]
    local rz0 = 90 * (4 - direction_sign - 2 * math.abs(side_index - 2.5)) --({0,180,180,0})[Sdn]
    for i = 1, sampled_point_count do
        local x2, y2 = sampled_x[direction_sign * (i + 1)], sampled_y[direction_sign * (i + 1)]
        local segment_length = math.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0))
        local rotation_degrees = additional_angle
        if auto_direction then
            rotation_degrees = rotation_degrees + math.atan2(y2 - y0, x2 - x0) / math.pi * 180 + rz0
        end
        while segment_length > next_draw_distance do
            local segment_ratio = next_draw_distance / segment_length
            local x, y = (1 - segment_ratio) * x0 + segment_ratio * x1, (1 - segment_ratio) * y0 + segment_ratio * y1
            if 2 * direction_sign * ((1 - swap_axes) * x + swap_axes * y) > side_length then
                return
            end
            obj.draw(x + center_x, y + center_y, 0, 1, 1, 0, 0, rotation_degrees)
            next_draw_distance = next_draw_distance + dot_spacing
        end
        next_draw_distance = next_draw_distance - segment_length
        x0, y0, x1, y1 = x1, y1, x2, y2
    end
end
local draw_side = function(side_length, center_x, center_y, side_index, swap_axes)
    local sample_extent_count = math.ceil(side_length / fluctuation_length / 2) + 3
    local random_offsets = {}
    local random_seed = 4 * random_seeds[side_index] + side_index
    random_offsets[0] = fluctuation_amount * obj.rand(-500, 500, -2, random_seed) / 1000
    for i = 1, sample_extent_count do
        random_offsets[i] = fluctuation_amount * obj.rand(-500, 500, -(2 * i + 2), random_seed) / 1000
        random_offsets[-i] = fluctuation_amount * obj.rand(-500, 500, -(2 * i + 1), random_seed) / 1000
    end
    local sampled_x = {}
    local sampled_y = {}
    local sampled_point_count = -1
    local x0, y0, z0, x1, y1, z1, x2, y2, z2 =
        -fluctuation_length,
        random_offsets[-1],
        random_offsets[1],
        0,
        random_offsets[0],
        random_offsets[0],
        fluctuation_length,
        random_offsets[1],
        random_offsets[-1]
    for i = 0, sample_extent_count - 2 do
        local x3, y3, z3 = fluctuation_length * (i + 2), random_offsets[i + 2], random_offsets[-i - 2]
        for j = 0, subdivision_count - 1 do
            local t = j / subdivision_count
            sampled_point_count = sampled_point_count + 1
            sampled_x[sampled_point_count], sampled_y[sampled_point_count] =
                obj.interpolation(t, x0, y0, x1, y1, x2, y2, x3, y3)
            sampled_x[-sampled_point_count], sampled_y[-sampled_point_count] =
                obj.interpolation(t, -x0, z0, -x1, z1, -x2, z2, -x3, z3)
        end
        x0, y0, z0, x1, y1, z1, x2, y2, z2 = x1, y1, z1, x2, y2, z2, x3, y3, z3
    end
    if swap_axes == 1 then
        sampled_x, sampled_y = sampled_y, sampled_x
    end
    local x0_value, y0_value = sampled_x[0], sampled_y[0]
    local rotation_degrees = additional_angle
    if auto_direction then
        rotation_degrees = rotation_degrees
            + (
                    math.atan2(sampled_y[1] - sampled_y[-1], sampled_x[1] - sampled_x[-1]) / math.pi
                    + 1.5
                    - math.abs(side_index - 2.5)
                )
                * 180
    end
    obj.draw(x0_value + center_x, y0_value + center_y, 0, 1, 1, 0, 0, rotation_degrees)
    draw_points_along_curve(
        x0_value,
        y0_value,
        1,
        center_x,
        center_y,
        sampled_point_count,
        side_length,
        sampled_x,
        sampled_y,
        swap_axes,
        side_index
    )
    draw_points_along_curve(
        x0_value,
        y0_value,
        -1,
        center_x,
        center_y,
        sampled_point_count,
        side_length,
        sampled_x,
        sampled_y,
        swap_axes,
        side_index
    )
end
local frame_width, frame_height = frame_size, frame_size
local extension_length = frame_size * 2 * extension_ratio
local positive_extension_length = math.max(extension_length, 0)
local output_width, output_height
if single_line then
    output_height = line_width + 10
    output_width = output_height + frame_size + positive_extension_length
    output_height = output_height + math.abs(fluctuation_amount)
else
    if aspect_ratio > 0 then
        frame_height = frame_height * (1 - aspect_ratio)
    else
        frame_width = frame_width * (1 + aspect_ratio)
    end
    local frame_margin = math.abs(fluctuation_amount) + positive_extension_length + line_width + 10
    output_width, output_height = math.floor(frame_width + frame_margin), math.floor(frame_height + frame_margin)
end
obj.setoption(
    "drawtarget",
    "tempbuffer",
    output_width + (obj.screen_w - output_width) % 2,
    output_height + (obj.screen_h - output_height) % 2
)
if single_line then
    draw_side(frame_width + extension_length, 0, 0, 1, 0)
else
    draw_side(frame_width + extension_length, 0, -frame_height / 2, 1, 0) --上
    draw_side(frame_width + extension_length, 0, frame_height / 2, 2, 0) --下
    draw_side(frame_height + extension_length, -frame_width / 2, 0, 3, 1) --左
    draw_side(frame_height + extension_length, frame_width / 2, 0, 4, 1) --右
end
obj.copybuffer("object", "tempbuffer")
for i = 2, overdraw_count do
    obj.draw()
    obj.copybuffer("object", "tempbuffer")
end
