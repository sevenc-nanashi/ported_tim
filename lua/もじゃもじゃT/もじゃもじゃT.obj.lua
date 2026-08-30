--label:${ROOT_CATEGORY}\カスタムオブジェクト
---$track:サイズ
---min=1
---max=2000
---step=1
local track_size = 200

---$track:誤差％
---min=0
---max=100
---step=0.1
local track_percent = 30

---$track:線幅
---min=1
---max=200
---step=1
local track_line_width = 6

---$track:巻き数
---min=0
---max=200
---step=0.01
local track_count = 5

---$check:時間展開
local check_time_expansion = false

---$color:色
local param_color = 0xff0000

---$track:間隔
---min=0
---max=600
---step=0.1
local param_spacing = 0

---$track:中心ずれX
---min=-1000
---max=1000
---step=0.1
local param_center_offset_x = 0

---$track:中心ずれY
---min=-1000
---max=1000
---step=0.1
local param_center_offset_y = 0

local param_center_offset = { param_center_offset_x, param_center_offset_y }

---$track:減衰速度％
---min=-100
---max=100
---step=0.1
local param_attenuation_percent = 0

---$track:減衰形状
---min=0
---max=20
---step=0.1
local param_attenuation_shape = 0

---$track:円状
---min=0
---max=100
---step=0.1
local param_circle_ratio = 100

---$track:開始角度
---min=-360
---max=360
---step=0.1
local param_start_angle = 0

---$track:半径ｵﾌｾｯﾄ
---min=-1000
---max=1000
---step=0.1
local param_radius_offset = 0

---$track:誤差比
---min=-100
---max=100
---step=0.1
local param_error_balance = 0

---$select:時間展開法
---等速度=0
---等角速度=1
---反転等速度=2
---反転等角速度=3
local param_time_expand_mode = 0

---$track:周分割
---min=3
---max=30
---step=1
local param_circumference_divisions = 4

---$track:分解能
---min=1
---max=50
---step=1
local param_resolution = 40

---$track:重ね描き
---min=0
---max=20
---step=1
local param_overdraw_count = 0

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
local param_seed_step = 0

--group:

---$value:PI
local param_override = {}

--hide@param_time_expand_mode:check_time_expansion==0

local pi = math.pi
local sin = math.sin
local cos = math.cos
local max = math.max
local min = math.min
local abs = math.abs
local sqrt = math.sqrt
local floor = math.floor
local ceil = math.ceil
param_override = param_override or {}
local size = (param_override[1] or track_size) / 2
local radius_variation = (param_override[2] or track_percent) / 100
local line_width = floor(param_override[3] or track_line_width)
local turn_count = param_override[4] or track_count
local color = param_color or 0xffffff
local spacing = abs(param_spacing or 2)
if spacing < 1 then
    spacing = math.log(line_width)
    spacing = (0.5126 * spacing + 0.4641) * spacing
    spacing = math.max(spacing, 1)
end
local center_offset = param_center_offset or { 0, 0 }
center_offset[1] = (center_offset[1] or 0) / turn_count
center_offset[2] = abs(center_offset[2] or 0) / turn_count
local attenuation_percent = abs(param_attenuation_percent or 0) / 100
local attenuation_shape = abs(param_attenuation_shape or 0) + 1
local circle_ratio = (param_circle_ratio or 100) / 100
circle_ratio = max(circle_ratio, 0)
circle_ratio = min(circle_ratio, 1)
local time_expand_mode = param_time_expand_mode or 0
local f0 = math.rad(param_start_angle or 0)
local radius_offset = abs(param_radius_offset or 0)
local error_balance = (param_error_balance or 0) / 100
error_balance = max(error_balance, -1)
error_balance = min(error_balance, 1)
local radius_variation_1 = (error_balance >= 0 and 1 or 1 + error_balance) * radius_variation
local radius_variation_2 = (error_balance >= 0 and 1 - error_balance or 1) * radius_variation
local circumference_divisions = floor(param_circumference_divisions or 4)
circumference_divisions = max(circumference_divisions, 3)
circumference_divisions = min(circumference_divisions, 30)
local resolution = floor(abs(param_resolution or 10))
resolution = max(resolution, 1)
resolution = min(resolution, 50)
local overdraw_count = floor(abs(param_overdraw_count or 0))
if overdraw_count == 0 then
    if line_width < 4 then
        overdraw_count = ({ 5, 3, 2 })[line_width]
    else
        overdraw_count = 1
    end
end
local seed = abs(param_seed or 0) + 1
local seed_step = floor(param_seed_step or 0)
local time_expand = param_override[0] == nil and check_time_expansion or param_override[0]
-- param_override = nil
-- param_color = nil
-- param_spacing = nil
-- param_center_offset = nil
-- param_attenuation_percent = nil
-- param_attenuation_shape = nil
-- param_circle_ratio = nil
-- param_time_expand_mode = nil
-- param_start_angle = nil
-- param_radius_offset = nil
-- param_error_balance = nil
-- param_circumference_divisions = nil
-- param_resolution = nil
-- param_overdraw_count = nil
-- param_seed = nil
-- param_seed_step = nil
obj.load("figure", "円", color, line_width * 2)
obj.effect("リサイズ", "拡大率", 50)
if turn_count == 0 then
    obj.alpha = 0
else
    local interpolation_strength = 0.6
    if circumference_divisions == 3 then
        interpolation_strength = 0.44
    elseif circumference_divisions == 4 then
        interpolation_strength = 0.55
    end
    local interpolation
    if radius_variation >= 0.1 then
        interpolation = obj.interpolation
    else
        interpolation = function(t, prev_x, prev_y, cur_x, cur_y, next_x, next_y, next2_x, next2_y)
            local x, y = obj.interpolation(t, prev_x, prev_y, cur_x, cur_y, next_x, next_y, next2_x, next2_y)
            local x21, y21 = next_x - cur_x, next_y - cur_y
            local dx1, dy1 = next_x - prev_x, next_y - prev_y
            local dx2, dy2 = cur_x - next2_x, cur_y - next2_y
            local determinant = dx2 * dy1 - dx1 * dy2
            local coefficient_a = (-dy2 * x21 + dx2 * y21) / determinant * interpolation_strength
            local coefficient_b = (-dy1 * x21 + dx1 * y21) / determinant * interpolation_strength
            coefficient_a = min(coefficient_a, 0.75)
            coefficient_a = max(coefficient_a, 0)
            coefficient_b = min(coefficient_b, 0.75)
            coefficient_b = max(coefficient_b, 0)
            local it = 1 - t
            local u1, v1 = cur_x + coefficient_a * dx1, cur_y + coefficient_a * dy1
            local u2, v2 = next_x + coefficient_b * dx2, next_y + coefficient_b * dy2
            local bezier_x1, bezier_y1 = it * cur_x + t * u1, it * cur_y + t * v1
            local bezier_x2, bezier_y2 = it * u1 + t * u2, it * v1 + t * v2
            local bezier_x3, bezier_y3 = it * u2 + t * next_x, it * v2 + t * next_y
            bezier_x1, bezier_y1 = it * bezier_x1 + t * bezier_x2, it * bezier_y1 + t * bezier_y2
            bezier_x2, bezier_y2 = it * bezier_x2 + t * bezier_x3, it * bezier_y2 + t * bezier_y3
            bezier_x1, bezier_y1 = it * bezier_x1 + t * bezier_x2, it * bezier_y1 + t * bezier_y2
            local s = radius_variation / 0.1
            x, y = (1 - s) * bezier_x1 + s * x, (1 - s) * bezier_y1 + s * y
            return x, y
        end
    end
    if seed_step > 0 then
        seed = seed + floor(obj.time * obj.framerate / seed_step)
    end
    center_offset[1] = center_offset[1] / circumference_divisions
    center_offset[2] = center_offset[2] / circumference_divisions
    local rounded_turn_count = ceil(turn_count)
    local point_count = circumference_divisions * rounded_turn_count
    local points_y = {}
    local points_x = {}
    for i = -1, point_count + 1 do
        local radius = size * (1 + radius_variation_1 * obj.rand(-1000, 1000 * 0, -seed, 2 * i + 3) / 1000)
        local f = 2
                * pi
                / circumference_divisions
                * (i + radius_variation_2 * obj.rand(-1000, 1000, -seed, 2 * i + 4) / 1000)
            + f0
        local x = max(1 - i / point_count, 0)
        x = min(x, 1)
        radius = radius * (1 - attenuation_percent * (1 - math.pow(x, attenuation_shape))) + radius_offset
        radius = radius > 0 and (radius < size and radius or size) or 0
        points_x[i] = radius * sin(f)
        points_y[i] = radius * cos(f)
    end
    local half_point_count = point_count / 2
    local ocx = center_offset[1] * half_point_count
    local ocy = center_offset[2] * half_point_count
    local interpolated_y = {}
    local interpolated_x = {}
    for i = 0, point_count - 1 do
        local x0, y0, x1, y1, x2, y2, x3, y3 =
            points_x[i - 1],
            points_y[i - 1],
            points_x[i],
            points_y[i],
            points_x[i + 1],
            points_y[i + 1],
            points_x[i + 2],
            points_y[i + 2]
        for s = 0, resolution - 1 do
            local k = resolution * i + s
            local resolution_ratio = s / resolution
            local x, y = interpolation(resolution_ratio, x0, y0, x1, y1, x2, y2, x3, y3)
            interpolated_x[k], interpolated_y[k] =
                x + center_offset[1] * ((i + resolution_ratio) - half_point_count),
                -circle_ratio * y + center_offset[2] * ((i + resolution_ratio) - half_point_count)
        end
    end
    local x, y =
        points_x[point_count] + center_offset[1] * half_point_count,
        -circle_ratio * points_y[point_count] + center_offset[2] * half_point_count
    local sample_count = resolution * point_count
    interpolated_x[sample_count] = x
    interpolated_y[sample_count] = y
    local calc_max_dimension = function(values, screen_size, max_limit)
        local max_value = values[0]
        local min_value = values[0]
        local value_count = #values
        for i = 1, value_count do
            max_value = max_value < values[i] and values[i] or max_value
        end
        for i = 1, value_count do
            min_value = min_value > values[i] and values[i] or min_value
        end
        max_value = max(abs(max_value), abs(min_value))
        max_value = floor(max_value + line_width / 2 + 5)
        max_value = 2 * max_value + screen_size % 2
        return min(max_value, max_limit)
    end
    local max_x, max_y = obj.getinfo("image_max")
    local max_buffer_width = calc_max_dimension(interpolated_x, obj.screen_w, max_x)
    local max_buffer_height = calc_max_dimension(interpolated_y, obj.screen_h, max_y)
    obj.setoption("drawtarget", "tempbuffer", max_buffer_width, max_buffer_height)
    turn_count = sample_count * turn_count / rounded_turn_count
    point_count = floor(turn_count)
    local partial_turn = turn_count - point_count
    local final_time = point_count
    if partial_turn > 0 then
        turn_count = point_count + 1
        interpolated_x[turn_count], interpolated_y[turn_count], final_time =
            (1 - partial_turn) * interpolated_x[point_count] + partial_turn * interpolated_x[turn_count],
            (1 - partial_turn) * interpolated_y[point_count] + partial_turn * interpolated_y[turn_count],
            (1 - partial_turn) * point_count + partial_turn * turn_count
    end
    local draw_x = {}
    local draw_y = {}
    local draw_time = {}
    local x0, y0, t0, distance_accumulator, draw_count = interpolated_x[0], interpolated_y[0], 0, 0, 0
    for i = 1, turn_count do
        local current_time = i < turn_count and i or final_time
        local x1, y1, t1 = interpolated_x[i], interpolated_y[i], current_time
        local dx, dy = (x1 - x0), (y1 - y0)
        local segment_length = sqrt(dx * dx + dy * dy)
        if distance_accumulator > segment_length then
            distance_accumulator = distance_accumulator - segment_length
        else
            local remaining_distance = segment_length - distance_accumulator
            local n = floor(remaining_distance / spacing)
            for k = 0, n do
                local t = distance_accumulator / segment_length
                draw_count = draw_count + 1
                draw_x[draw_count], draw_y[draw_count], draw_time[draw_count] =
                    (1 - t) * x0 + t * x1, (1 - t) * y0 + t * y1, (1 - t) * t0 + t * t1
                distance_accumulator = distance_accumulator + spacing
            end
            distance_accumulator = distance_accumulator - segment_length
        end
        x0, y0, t0 = x1, y1, t1
    end
    local start_index, end_index, step_index = 1, draw_count, 1
    if time_expand then
        local t = obj.time / obj.totaltime
        if time_expand_mode == 1 then
            local target_time = draw_time[draw_count] * t
            for i = 1, draw_count do
                if draw_time[i] > target_time then
                    break
                end
                end_index = i
            end
        elseif time_expand_mode == 2 then
            start_index, end_index, step_index = draw_count, draw_count - (draw_count - 1) * t, -1
        elseif time_expand_mode == 3 then
            local target_time = draw_time[draw_count] * (1 - t)
            for i = draw_count, 1, -1 do
                if draw_time[i] < target_time then
                    break
                end
                end_index = i
            end
            start_index, step_index = draw_count, -1
        else
            end_index = 1 + (draw_count - 1) * t
        end
    end
    for i = start_index, end_index, step_index do
        obj.draw(draw_x[i], draw_y[i])
    end
    obj.copybuffer("object", "tempbuffer")
    for i = 2, overdraw_count do
        obj.draw()
        obj.copybuffer("object", "tempbuffer")
    end
    obj.cx = -ocx
    obj.cy = -ocy
end
