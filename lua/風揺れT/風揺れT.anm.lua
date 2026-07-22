--label:${ROOT_CATEGORY}\アニメーション効果
---$track:揺れ角
---min=0
---max=360
---step=0.1
local sway_angle = 30

---$track:揺れ周期
---min=0.01
---max=100
---step=0.01
local sway_period = 2

---$track:揺れズレ
---min=-360
---max=360
---step=0.1
local sway_phase_offset = 90

---$track:センター
---min=-180
---max=180
---step=0.1
local center_angle = 0

---$track:分割数
---min=2
---max=300
---step=1
local segment_count = 10

---$track:上固定長％
---min=0
---max=100
---step=0.1
local top_fixed_percent = 10

---$track:下固定長％
---min=0
---max=100
---step=0.1
local bottom_fixed_percent = 10

---$check:下を基準
local anchor_at_bottom = 0

---$check:ランダム揺れ量
local randomize_sway = 0

---$track:ランダム揺れパターン
---min=0
---max=10000
---step=1
local random_pattern = 0

---$track:時間ずれ
---min=-10
---max=10
---step=0.01
local time_offset = 0.1

---$check:横に繰り返す
local repeat_horizontally = 0

---$track:繰り返し個数
---min=1
---max=50
---step=1
local repeat_count = 3

---$track:間隔
---min=0
---max=1000
---step=0.1
local repeat_spacing = 50

---$check:破綻軽減
local reduce_distortion = 0

---$check:アルファ補正
local correct_alpha = true

--[[pixelshader@extract_straight_color
---$include "./shaders/alpha_correction.hlsl"
]]
--[[pixelshader@extract_alpha
---$include "./shaders/alpha_correction.hlsl"
]]
--[[pixelshader@combine_color_alpha
---$include "./shaders/alpha_correction.hlsl"
]]

--[[
NOTE: https://github.com/kanade-ak/kazeyureT を参考に高速化されました。

MIT License

Copyright (c) 2026 kanade-ak

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local object_width, object_height = obj.getpixel()
local half_width, half_height = object_width / 2, object_height / 2
local base_time = obj.time

if anchor_at_bottom == 1 then
    top_fixed_percent, bottom_fixed_percent = bottom_fixed_percent, top_fixed_percent
end
if top_fixed_percent < 0 then
    top_fixed_percent = 0
elseif top_fixed_percent > 100 then
    top_fixed_percent = 100
end
if bottom_fixed_percent < 0 then
    bottom_fixed_percent = 0
elseif bottom_fixed_percent > 100 - top_fixed_percent then
    bottom_fixed_percent = 100 - top_fixed_percent
end

local top_fixed_length = top_fixed_percent * 0.01 * object_height
local bottom_fixed_length = bottom_fixed_percent * 0.01 * object_height
local flexible_length = object_height - top_fixed_length - bottom_fixed_length
local sway_amplitude = math.pi * sway_angle / 180
local angular_velocity = 2 * math.pi / sway_period
local phase_offset = 2 * sway_phase_offset * math.pi / 180
local center_angle_radians = center_angle * math.pi / 180
local random_seed = 10 + math.abs(random_pattern)

local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local floor = math.floor

local function build_wind_geometry(repeat_index)
    local render_time = base_time - repeat_index * time_offset
    local current_sway_amplitude = sway_amplitude
    if randomize_sway == 1 then
        local cycle_position = render_time / sway_period
        local current_cycle = floor(cycle_position)
        local previous_cycle = current_cycle - 1
        local next_cycle = current_cycle + 1
        local following_cycle = current_cycle + 2
        local previous_random_index = previous_cycle + 1
        local current_random_index = current_cycle + 1
        local next_random_index = next_cycle + 1
        local following_random_index = following_cycle + 1

        if previous_cycle < 0 then
            previous_random_index = 10000 - previous_cycle
        end
        if current_cycle < 0 then
            current_random_index = 10000 - current_cycle
        end
        if next_cycle < 0 then
            next_random_index = 10000 - next_cycle
        end
        if following_cycle < 0 then
            following_random_index = 10000 - following_cycle
        end

        local cycle_fraction = cycle_position - current_cycle
        local previous_sway = obj.rand(0, 1000, -random_seed, previous_random_index) * sway_amplitude * 0.001
        local current_sway = obj.rand(0, 1000, -random_seed, current_random_index) * sway_amplitude * 0.001
        local next_sway = obj.rand(0, 1000, -random_seed, next_random_index) * sway_amplitude * 0.001
        local following_sway = obj.rand(0, 1000, -random_seed, following_random_index) * sway_amplitude * 0.001
        current_sway_amplitude =
            obj.interpolation(cycle_fraction, previous_sway, current_sway, next_sway, following_sway)
    end

    local base_segment_count = segment_count
    local geometry_segment_count = base_segment_count
    local inverse_segment_count = 1 / base_segment_count
    local segment_length = flexible_length * inverse_segment_count
    local center_x_positions = { [0] = 0 }
    local center_y_positions = { [0] = top_fixed_length - half_height }
    local texture_y_positions = { [0] = top_fixed_length }
    local phase_per_segment = phase_offset * inverse_segment_count
    local phase_step_sin = sin(phase_per_segment)
    local phase_step_cos = cos(phase_per_segment)
    local wave_sin = sin(angular_velocity * render_time - phase_per_segment)
    local wave_cos = cos(angular_velocity * render_time - phase_per_segment)

    for segment_index = 1, base_segment_count do
        local taper = 1 - segment_index * inverse_segment_count
        local taper2 = taper * taper
        local bend_angle = (current_sway_amplitude * wave_sin + center_angle_radians) * (1 - taper2 * taper2)
        center_x_positions[segment_index] = center_x_positions[segment_index - 1] + sin(bend_angle) * segment_length
        center_y_positions[segment_index] = center_y_positions[segment_index - 1] + cos(bend_angle) * segment_length
        texture_y_positions[segment_index] = segment_length * segment_index + top_fixed_length

        if segment_index < base_segment_count then
            if segment_index % 64 == 0 then
                local phase = angular_velocity * render_time - (segment_index + 1) * phase_per_segment
                wave_sin = sin(phase)
                wave_cos = cos(phase)
            else
                local next_wave_sin = wave_sin * phase_step_cos - wave_cos * phase_step_sin
                wave_cos = wave_cos * phase_step_cos + wave_sin * phase_step_sin
                wave_sin = next_wave_sin
            end
        end
    end

    center_x_positions[-1] = 0
    center_y_positions[-1] = -half_height
    texture_y_positions[-1] = 0
    local left_x_positions = { [-1] = -half_width }
    local right_x_positions = { [-1] = half_width }
    local left_y_positions = { [-1] = -half_height }
    local right_y_positions = { [-1] = -half_height }

    for segment_index = 0, base_segment_count do
        local direction_x = center_x_positions[segment_index] - center_x_positions[segment_index - 1]
        local direction_y = center_y_positions[segment_index] - center_y_positions[segment_index - 1]
        local direction_length = sqrt(direction_x * direction_x + direction_y * direction_y)
        if direction_length > 0 then
            local normal_x = -direction_y / direction_length * half_width
            local normal_y = direction_x / direction_length * half_width
            left_x_positions[segment_index] = center_x_positions[segment_index] + normal_x
            right_x_positions[segment_index] = center_x_positions[segment_index] - normal_x
            left_y_positions[segment_index] = center_y_positions[segment_index] + normal_y
            right_y_positions[segment_index] = center_y_positions[segment_index] - normal_y
        else
            left_x_positions[segment_index] = left_x_positions[segment_index - 1]
            right_x_positions[segment_index] = right_x_positions[segment_index - 1]
            left_y_positions[segment_index] = left_y_positions[segment_index - 1]
            right_y_positions[segment_index] = right_y_positions[segment_index - 1]
        end
    end

    if bottom_fixed_length > 0 then
        local direction_x = center_x_positions[base_segment_count] - center_x_positions[base_segment_count - 1]
        local direction_y = center_y_positions[base_segment_count] - center_y_positions[base_segment_count - 1]
        local direction_length = sqrt(direction_x * direction_x + direction_y * direction_y)
        assert(direction_length > 0, "Segment length must be positive")

        local extension_x = direction_x / direction_length * bottom_fixed_length
        local extension_y = direction_y / direction_length * bottom_fixed_length
        local extension_index = base_segment_count + 1
        left_x_positions[extension_index] = left_x_positions[base_segment_count] + extension_x
        right_x_positions[extension_index] = right_x_positions[base_segment_count] + extension_x
        left_y_positions[extension_index] = left_y_positions[base_segment_count] + extension_y
        right_y_positions[extension_index] = right_y_positions[base_segment_count] + extension_y
        texture_y_positions[extension_index] = object_height
        geometry_segment_count = extension_index
    end

    local min_x = -half_width
    local max_x = half_width
    local min_y = -half_height
    local max_y = -half_height
    for segment_index = 0, geometry_segment_count do
        if min_x > left_x_positions[segment_index] then
            min_x = left_x_positions[segment_index]
        elseif max_x < left_x_positions[segment_index] then
            max_x = left_x_positions[segment_index]
        end
        if min_x > right_x_positions[segment_index] then
            min_x = right_x_positions[segment_index]
        elseif max_x < right_x_positions[segment_index] then
            max_x = right_x_positions[segment_index]
        end
        if min_y > left_y_positions[segment_index] then
            min_y = left_y_positions[segment_index]
        elseif max_y < left_y_positions[segment_index] then
            max_y = left_y_positions[segment_index]
        end
        if min_y > right_y_positions[segment_index] then
            min_y = right_y_positions[segment_index]
        elseif max_y < right_y_positions[segment_index] then
            max_y = right_y_positions[segment_index]
        end
    end

    local bounds_width = max_x - min_x
    local bounds_height = max_y - min_y
    local bounds_center_x = (max_x + min_x) * 0.5
    local bounds_center_y = (max_y + min_y) * 0.5
    local vertices = {}
    local vertex_count = 0

    if reduce_distortion == 1 then
        for segment_index = 0, geometry_segment_count do
            local x0 = left_x_positions[segment_index - 1] - bounds_center_x
            local y0 = left_y_positions[segment_index - 1] - bounds_center_y
            local x1 = right_x_positions[segment_index - 1] - bounds_center_x
            local y1 = right_y_positions[segment_index - 1] - bounds_center_y
            local x2 = right_x_positions[segment_index] - bounds_center_x
            local y2 = right_y_positions[segment_index] - bounds_center_y
            local x3 = left_x_positions[segment_index] - bounds_center_x
            local y3 = left_y_positions[segment_index] - bounds_center_y
            local v0 = texture_y_positions[segment_index - 1]
            local v1 = texture_y_positions[segment_index]
            local xc = (x0 + x1 + x2 + x3) * 0.25
            local yc = (y0 + y1 + y2 + y3) * 0.25
            local vc = (v0 + v1) * 0.5
            vertices[vertex_count + 1] =
                { x0, y0, 0, x1, y1, 0, xc, yc, 0, xc, yc, 0, 0, v0, object_width, v0, half_width, vc, half_width, vc }
            vertices[vertex_count + 2] = {
                x1,
                y1,
                0,
                x2,
                y2,
                0,
                xc,
                yc,
                0,
                xc,
                yc,
                0,
                object_width,
                v0,
                object_width,
                v1,
                half_width,
                vc,
                half_width,
                vc,
            }
            vertices[vertex_count + 3] =
                { x3, y3, 0, x0, y0, 0, xc, yc, 0, xc, yc, 0, 0, v1, 0, v0, half_width, vc, half_width, vc }
            vertices[vertex_count + 4] =
                { x2, y2, 0, x3, y3, 0, xc, yc, 0, xc, yc, 0, object_width, v1, 0, v1, half_width, vc, half_width, vc }
            vertex_count = vertex_count + 4
        end
    else
        for segment_index = 0, geometry_segment_count do
            local x0 = left_x_positions[segment_index - 1] - bounds_center_x
            local y0 = left_y_positions[segment_index - 1] - bounds_center_y
            local x1 = right_x_positions[segment_index - 1] - bounds_center_x
            local y1 = right_y_positions[segment_index - 1] - bounds_center_y
            local x2 = right_x_positions[segment_index] - bounds_center_x
            local y2 = right_y_positions[segment_index] - bounds_center_y
            local x3 = left_x_positions[segment_index] - bounds_center_x
            local y3 = left_y_positions[segment_index] - bounds_center_y
            local v0 = texture_y_positions[segment_index - 1]
            local v1 = texture_y_positions[segment_index]
            vertex_count = vertex_count + 1
            vertices[vertex_count] =
                { x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, 0, v0, object_width, v0, object_width, v1, 0, v1 }
        end
    end

    return vertices, bounds_width, bounds_height, bounds_center_x, bounds_center_y
end

local function draw_wind_geometry(vertices, bounds_width, bounds_height)
    obj.setoption("drawtarget", "tempbuffer", bounds_width, bounds_height)
    obj.setoption("blend", "alpha_add2")
    obj.drawpoly(vertices)

    if correct_alpha then
        obj.copybuffer("cache:color", "tempbuffer")
        obj.pixelshader("extract_alpha", "object", "cache:original")
        obj.setoption("drawtarget", "tempbuffer", bounds_width, bounds_height)
        obj.setoption("blend", "alpha_add2")
        obj.drawpoly(vertices)
        obj.copybuffer("object", "tempbuffer")
        obj.pixelshader("combine_color_alpha", "tempbuffer", {
            "cache:color",
            "object",
        })
        obj.setoption("blend", "none")
    end
end

local function render_wind_geometry(repeat_index)
    local vertices, bounds_width, bounds_height, bounds_center_x, bounds_center_y = build_wind_geometry(repeat_index)
    draw_wind_geometry(vertices, bounds_width, bounds_height)
    return bounds_width, bounds_height, bounds_center_x, bounds_center_y
end

local function append_translated_vertices(destination, destination_count, source, delta_x, delta_y)
    for i = 1, #source do
        local vertex = source[i]
        destination_count = destination_count + 1
        destination[destination_count] = {
            vertex[1] + delta_x,
            vertex[2] + delta_y,
            vertex[3],
            vertex[4] + delta_x,
            vertex[5] + delta_y,
            vertex[6],
            vertex[7] + delta_x,
            vertex[8] + delta_y,
            vertex[9],
            vertex[10] + delta_x,
            vertex[11] + delta_y,
            vertex[12],
            vertex[13],
            vertex[14],
            vertex[15],
            vertex[16],
            vertex[17],
            vertex[18],
            vertex[19],
            vertex[20],
        }
    end
    return destination_count
end

if anchor_at_bottom == 1 then
    obj.effect("反転", "上下反転", 1)
end
if correct_alpha then
    obj.copybuffer("cache:original", "object")
    obj.pixelshader("extract_straight_color", "object", "object")
end
if repeat_horizontally == 0 then
    local _, _, bounds_center_x, bounds_center_y = render_wind_geometry(1)
    obj.load("tempbuffer")
    obj.cx = -bounds_center_x
    if anchor_at_bottom == 1 then
        obj.effect("反転", "上下反転", 1)
        obj.cy = bounds_center_y
    else
        obj.cy = -bounds_center_y
    end
elseif not correct_alpha and anchor_at_bottom == 0 then
    local vertices = {}
    local vertex_count = 0
    local repeat_center = (repeat_count + 1) * 0.5

    if time_offset == 0 then
        local source_vertices, _, _, bounds_center_x, bounds_center_y = build_wind_geometry(1)
        for repeat_index = 1, repeat_count do
            local offset_x = (repeat_index - repeat_center) * repeat_spacing + bounds_center_x
            vertex_count =
                append_translated_vertices(vertices, vertex_count, source_vertices, offset_x, bounds_center_y)
        end
    else
        for repeat_index = 1, repeat_count do
            local source_vertices, _, _, bounds_center_x, bounds_center_y = build_wind_geometry(repeat_index)
            local offset_x = (repeat_index - repeat_center) * repeat_spacing + bounds_center_x
            vertex_count =
                append_translated_vertices(vertices, vertex_count, source_vertices, offset_x, bounds_center_y)
        end
    end

    obj.setoption("drawtarget", "framebuffer")
    obj.setoption("blend", "alpha_add2")
    obj.drawpoly(vertices)
else
    obj.copybuffer("cache:rep_original", "object")
    for repeat_index = 1, repeat_count do
        obj.copybuffer("object", "cache:rep_original")
        local _, _, bounds_center_x, bounds_center_y = render_wind_geometry(repeat_index)
        bounds_center_x = (repeat_index - (repeat_count + 1) * 0.5) * repeat_spacing + bounds_center_x
        obj.load("tempbuffer")
        obj.setoption("drawtarget", "framebuffer")

        if anchor_at_bottom == 1 then
            obj.effect("反転", "上下反転", 1)
            obj.draw(bounds_center_x, -bounds_center_y)
        else
            obj.draw(bounds_center_x, bounds_center_y)
        end
    end
end
