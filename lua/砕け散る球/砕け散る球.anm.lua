--label:${ROOT_CATEGORY}\アニメーション効果
---$track:粉砕度
---min=0
---max=5000
---step=0.1
local track_shatter_amount = 100

---$track:時間差
---min=0
---max=1000
---step=0.1
local track_time_offset = 100

---$track:半径
---min=10
---max=10000
---step=0.1
local track_radius = 300

---$track:限界距離
---min=0
---max=10000
---step=0.1
local track_limit_distance = 150

---$track:厚さ
---min=0
---max=500
---step=0.1
local track_thickness = 20

---$track:破片サイズ
---min=1
---max=500
---step=0.1
local track_fragment_size = 40

---$track:ランダム形状
---min=0
---max=100
---step=0.1
local track_random_shape = 100

--group:中心
---$track:中心X
---min=-2000
---max=2000
---step=0.1
local track_center_x = 0

---$track:中心Y
---min=-2000
---max=2000
---step=0.1
local track_center_y = 0

---$track:中心Z
---min=-2000
---max=2000
---step=0.1
local track_center_z = 0

--group

---$track:速度
---min=-1000
---max=1000
---step=0.1
local track_speed = 100

---$track:距離影響
---min=0
---max=500
---step=0.1
local track_distance_impact = 100

---$track:円周方向初速度
---min=-1000
---max=1000
---step=0.1
local track_tangential_speed = 0

--group:重力
---$track:重力X
---min=-1000
---max=1000
---step=0.1
local track_gravity_x = 0

---$track:重力Y
---min=-1000
---max=1000
---step=0.1
local track_gravity_y = 100

---$track:重力Z
---min=-1000
---max=1000
---step=0.1
local track_gravity_z = 0

--group

---$track:ランダム回転
---min=0
---max=500
---step=0.1
local track_random_rotation = 100

---$track:ランダム方向
---min=0
---max=500
---step=0.1
local track_random_direction = 100

local grid_x = {}
local grid_y = {}
local outer_x = {}
local outer_y = {}
local outer_z = {}
local inner_x = {}
local inner_y = {}
local inner_z = {}
local texture_u = {}
local texture_v = {}
local fragment_state = {}
local fragment_times = {}
local center_values = string.format("%s,%s,%s", track_center_x, track_center_y, track_center_z)
local gravity_values = string.format("%s,%s,%s", track_gravity_x, track_gravity_y, track_gravity_z)

local vertices = {}

local flush_vertices = function()
    if #vertices == 0 then
        return
    end
    obj.drawpoly(vertices)
    vertices = {}
end

local push_quad = function(...)
    vertices[#vertices + 1] = { ... }
end

obj.effect()

local pi, shatter_progress, delay, limit_distance, sphere_radius, image_width, image_height, speed_scale, w, h, image_diagonal, random_offset_x, random_offset_y
local bottom_left_index, n2, gravity_x, gravity_y, gravity_z, center_x, center_y, center_z, fragment_center_y, top_left_index, distance_squared, center_distance, current_fragment_state
local fragment_center_x, fragment_center_y_3d, fragment_center_z, velocity_x, velocity_y, velocity_z, fragment_time, horizontal_center_distance, fragment_center_x_2d, distance_attenuation, translated_center_x, translated_center_y, translated_center_z, rotated_x, rotated_y, rotated_z
local sin_x, cos_x, sin_y, cos_y, sin_z, cos_z
local m00, m01, m02, m10, m11, m12, m20, m21, m22

pi = math.pi
shatter_progress = track_shatter_amount / 1000
delay = track_time_offset
limit_distance = track_limit_distance
sphere_radius = track_radius
delay = delay * 0.002
track_distance_impact = track_distance_impact * 0.2
track_random_rotation = math.floor(track_random_rotation * 10)
track_random_direction = track_random_direction / 80
track_fragment_size = track_fragment_size * obj.w / (sphere_radius * 2 * pi)
if track_fragment_size < 10 then
    track_fragment_size = 10
end
track_random_shape = math.abs(track_random_shape * 0.5)
if track_random_shape >= 50 then
    track_random_shape = 50
end
image_width = obj.w
image_height = obj.h
speed_scale = track_speed * 0.05
w = math.floor(image_width / track_fragment_size)
h = math.floor(image_height / track_fragment_size)
image_diagonal = math.sqrt(image_width * image_width + image_height * image_height)
if w < 2 then
    w = 2
elseif w > image_width then
    w = image_width
end
if h < 2 then
    h = 2
elseif h > image_height then
    h = image_height
end
random_offset_x = image_width / w * 0.43 * track_random_shape / 100
random_offset_y = image_height / h * 0.43 * track_random_shape / 100

bottom_left_index, n2, gravity_x, gravity_y, gravity_z = string.find(gravity_values, "(.*),(.*),(.*)")
gravity_x = gravity_x * 6
gravity_y = gravity_y * 6
gravity_z = gravity_z * 6
bottom_left_index, n2, center_x, center_y, center_z = string.find(center_values, "(.*),(.*),(.*)")

for y = 0, h do
    for x = 0, w do
        grid_x[(w + 1) * y + x] = image_width * x / w + obj.rand(-random_offset_x, random_offset_x, x, y)
        grid_y[(w + 1) * y + x] = image_height * y / h + obj.rand(-random_offset_y, random_offset_y, x, y + 1000)
    end
end
for y = 0, h do
    grid_x[(w + 1) * y] = 0
    grid_x[(w + 1) * y + w] = image_width
    grid_y[(w + 1) * y + w] = grid_y[(w + 1) * y]
end
for x = 0, w do
    grid_y[x] = 0
    grid_y[(w + 1) * h + x] = image_height
end

for y = 0, h - 1 do
    fragment_center_y = track_fragment_size * y - image_height / 2
    for x = 0, w - 1 do
        top_left_index = (w + 1) * y + x
        bottom_left_index = (w + 1) * (y + 1) + x

        distance_squared = -sphere_radius
                * math.sin(pi * (track_fragment_size * y) / image_height)
                * math.cos(2 * pi * (track_fragment_size * x) / image_width + pi)
            + sphere_radius
        center_distance =
            math.sqrt((track_fragment_size * x - image_width / 2) ^ 2 + fragment_center_y * fragment_center_y)
        fragment_times[(w + 1) * y + x] = shatter_progress - 2 * center_distance / image_diagonal * delay
        fragment_state[(w + 1) * y + x] = 0
        if limit_distance >= 0 and distance_squared >= limit_distance + track_fragment_size then
            fragment_state[(w + 1) * y + x] = 2
        elseif limit_distance >= 0 and distance_squared >= limit_distance then
            fragment_state[(w + 1) * y + x] = 1
        end
    end
end

for y = 0, h - 1 do
    fragment_center_y = track_fragment_size * y - image_height / 2
    for x = 0, w - 1 do
        current_fragment_state = fragment_state[(w + 1) * y + x]
        top_left_index = (w + 1) * y + x
        bottom_left_index = (w + 1) * (y + 1) + x
        texture_u[0] = grid_x[top_left_index]
        texture_u[1] = grid_x[top_left_index + 1]
        texture_u[2] = grid_x[bottom_left_index + 1]
        texture_u[3] = grid_x[bottom_left_index]
        texture_v[0] = grid_y[top_left_index]
        texture_v[1] = grid_y[top_left_index + 1]
        texture_v[2] = grid_y[bottom_left_index + 1]
        texture_v[3] = grid_y[bottom_left_index]

        for i = 0, 3 do
            outer_x[i] = sphere_radius
                * math.sin(pi * texture_v[i] / image_height)
                * math.sin(2 * pi * texture_u[i] / image_width + pi)
            outer_y[i] = -sphere_radius * math.cos(pi * texture_v[i] / image_height)
            outer_z[i] = -sphere_radius
                * math.sin(pi * texture_v[i] / image_height)
                * math.cos(2 * pi * texture_u[i] / image_width + pi)

            inner_x[i] = (sphere_radius - track_thickness)
                * math.sin(pi * texture_v[i] / image_height)
                * math.sin(2 * pi * texture_u[i] / image_width + pi)
            inner_y[i] = -(sphere_radius - track_thickness) * math.cos(pi * texture_v[i] / image_height)
            inner_z[i] = -(sphere_radius - track_thickness)
                * math.sin(pi * texture_v[i] / image_height)
                * math.cos(2 * pi * texture_u[i] / image_width + pi)
        end

        -- 基準の計算
        fragment_center_x = (
            outer_x[0]
            + outer_x[1]
            + outer_x[2]
            + outer_x[3]
            + inner_x[0]
            + inner_x[1]
            + inner_x[2]
            + inner_x[3]
        ) / 8
        fragment_center_y_3d = (
            outer_y[0]
            + outer_y[1]
            + outer_y[2]
            + outer_y[3]
            + inner_y[0]
            + inner_y[1]
            + inner_y[2]
            + inner_y[3]
        ) / 8
        fragment_center_z = (
            outer_z[0]
            + outer_z[1]
            + outer_z[2]
            + outer_z[3]
            + inner_z[0]
            + inner_z[1]
            + inner_z[2]
            + inner_z[3]
        ) / 8

        velocity_x = fragment_center_x - center_x
        velocity_y = fragment_center_y_3d - center_y
        velocity_z = fragment_center_z - center_z

        fragment_time = fragment_times[(w + 1) * y + x]

        if (fragment_time < 0) or current_fragment_state ~= 0 then
            fragment_time = 0
        end

        horizontal_center_distance =
            math.sqrt(fragment_center_x * fragment_center_x + fragment_center_y_3d * fragment_center_y_3d)
        fragment_center_x_2d = track_fragment_size * x - image_width / 2
        distance_squared = fragment_center_x_2d * fragment_center_x_2d + fragment_center_y * fragment_center_y
        distance_attenuation = 1
            / (1 + 4 * distance_squared / (image_diagonal * image_diagonal) * track_distance_impact)
        velocity_x = velocity_x * distance_attenuation
            + obj.rand(-track_fragment_size, track_fragment_size, x, y + 4000) * track_random_direction
            + track_tangential_speed * fragment_center_x / horizontal_center_distance
        velocity_y = velocity_y * distance_attenuation
            + obj.rand(-track_fragment_size, track_fragment_size, x, y + 5000) * track_random_direction
        velocity_z = velocity_z * distance_attenuation
            + obj.rand(-track_fragment_size, track_fragment_size, x, y + 6000) * track_random_direction
            + track_tangential_speed * fragment_center_y_3d / horizontal_center_distance
        translated_center_x = fragment_center_x
            + fragment_time * velocity_x * speed_scale
            + fragment_time * fragment_time * gravity_x
        translated_center_y = fragment_center_y_3d
            + fragment_time * velocity_y * speed_scale
            + fragment_time * fragment_time * gravity_y
        translated_center_z = fragment_center_z
            + fragment_time * velocity_z * speed_scale
            + fragment_time * fragment_time * gravity_z

        -- 回転を計算

        rotated_x = fragment_time * obj.rand(-track_random_rotation, track_random_rotation, x, y + 2000) / 100
        rotated_y = fragment_time * obj.rand(-track_random_rotation, track_random_rotation, x, y + 3000) / 100
        rotated_z = fragment_time * obj.rand(-track_random_rotation, track_random_rotation, x, y + 4000) / 100
        sin_x = math.sin(rotated_x)
        cos_x = math.cos(rotated_x)
        sin_y = math.sin(rotated_y)
        cos_y = math.cos(rotated_y)
        sin_z = math.sin(rotated_z)
        cos_z = math.cos(rotated_z)
        m00 = cos_y * cos_z
        m01 = -cos_y * sin_z
        m02 = -sin_y
        m10 = cos_x * sin_z - sin_x * sin_y * cos_z
        m11 = cos_x * cos_z + sin_x * sin_y * sin_z
        m12 = -sin_x * cos_y
        m20 = sin_x * sin_z + cos_x * sin_y * cos_z
        m21 = sin_x * cos_z - cos_x * sin_y * sin_z
        m22 = cos_x * cos_y

        for i = 0, 3 do
            rotated_x = outer_x[i] - fragment_center_x
            rotated_y = outer_y[i] - fragment_center_y_3d
            rotated_z = outer_z[i] - fragment_center_z
            outer_x[i] = m00 * rotated_x + m01 * rotated_y + m02 * rotated_z + translated_center_x
            outer_y[i] = m10 * rotated_x + m11 * rotated_y + m12 * rotated_z + translated_center_y
            outer_z[i] = m20 * rotated_x + m21 * rotated_y + m22 * rotated_z + translated_center_z

            rotated_x = inner_x[i] - fragment_center_x
            rotated_y = inner_y[i] - fragment_center_y_3d
            rotated_z = inner_z[i] - fragment_center_z
            inner_x[i] = m00 * rotated_x + m01 * rotated_y + m02 * rotated_z + translated_center_x
            inner_y[i] = m10 * rotated_x + m11 * rotated_y + m12 * rotated_z + translated_center_y
            inner_z[i] = m20 * rotated_x + m21 * rotated_y + m22 * rotated_z + translated_center_z
        end

        push_quad(
            outer_x[0],
            outer_y[0],
            outer_z[0],
            outer_x[1],
            outer_y[1],
            outer_z[1],
            outer_x[2],
            outer_y[2],
            outer_z[2],
            outer_x[3],
            outer_y[3],
            outer_z[3],
            texture_u[0],
            texture_v[0],
            texture_u[1],
            texture_v[1],
            texture_u[2],
            texture_v[2],
            texture_u[3],
            texture_v[3]
        )
        push_quad(
            inner_x[0],
            inner_y[0],
            inner_z[0],
            inner_x[1],
            inner_y[1],
            inner_z[1],
            inner_x[2],
            inner_y[2],
            inner_z[2],
            inner_x[3],
            inner_y[3],
            inner_z[3],
            texture_u[0],
            texture_v[0],
            texture_u[1],
            texture_v[1],
            texture_u[2],
            texture_v[2],
            texture_u[3],
            texture_v[3]
        )
        if current_fragment_state == 0 and fragment_time > 0 then
            push_quad(
                outer_x[0],
                outer_y[0],
                outer_z[0],
                outer_x[1],
                outer_y[1],
                outer_z[1],
                inner_x[1],
                inner_y[1],
                inner_z[1],
                inner_x[0],
                inner_y[0],
                inner_z[0],
                texture_u[0],
                texture_v[0],
                texture_u[1],
                texture_v[1],
                texture_u[1],
                texture_v[1],
                texture_u[0],
                texture_v[0]
            )
            push_quad(
                outer_x[1],
                outer_y[1],
                outer_z[1],
                outer_x[2],
                outer_y[2],
                outer_z[2],
                inner_x[2],
                inner_y[2],
                inner_z[2],
                inner_x[1],
                inner_y[1],
                inner_z[1],
                texture_u[1],
                texture_v[1],
                texture_u[2],
                texture_v[2],
                texture_u[2],
                texture_v[2],
                texture_u[1],
                texture_v[1]
            )
            push_quad(
                outer_x[2],
                outer_y[2],
                outer_z[2],
                outer_x[3],
                outer_y[3],
                outer_z[3],
                inner_x[3],
                inner_y[3],
                inner_z[3],
                inner_x[2],
                inner_y[2],
                inner_z[2],
                texture_u[2],
                texture_v[2],
                texture_u[3],
                texture_v[3],
                texture_u[3],
                texture_v[3],
                texture_u[2],
                texture_v[2]
            )
            push_quad(
                outer_x[3],
                outer_y[3],
                outer_z[3],
                outer_x[0],
                outer_y[0],
                outer_z[0],
                inner_x[0],
                inner_y[0],
                inner_z[0],
                inner_x[3],
                inner_y[3],
                inner_z[3],
                texture_u[3],
                texture_v[3],
                texture_u[0],
                texture_v[0],
                texture_u[0],
                texture_v[0],
                texture_u[3],
                texture_v[3]
            )
        elseif current_fragment_state == 1 then
            if
                (y == 0 and fragment_state[(w + 1) * (h - 1) + x] == 0 and fragment_times[(w + 1) * (h - 1) + x] > 0)
                or (fragment_state[(w + 1) * (y - 1) + x] == 0 and fragment_times[(w + 1) * (y - 1) + x] > 0)
            then
                push_quad(
                    outer_x[0],
                    outer_y[0],
                    outer_z[0],
                    outer_x[1],
                    outer_y[1],
                    outer_z[1],
                    inner_x[1],
                    inner_y[1],
                    inner_z[1],
                    inner_x[0],
                    inner_y[0],
                    inner_z[0],
                    texture_u[0],
                    texture_v[0],
                    texture_u[1],
                    texture_v[1],
                    texture_u[1],
                    texture_v[1],
                    texture_u[0],
                    texture_v[0]
                )
            end
            if
                (x == w - 1 and fragment_state[(w + 1) * y] == 0 and fragment_times[(w + 1) * y] > 0)
                or (fragment_state[(w + 1) * y + x + 1] == 0 and fragment_times[(w + 1) * y + x + 1] > 0)
            then
                push_quad(
                    outer_x[1],
                    outer_y[1],
                    outer_z[1],
                    outer_x[2],
                    outer_y[2],
                    outer_z[2],
                    inner_x[2],
                    inner_y[2],
                    inner_z[2],
                    inner_x[1],
                    inner_y[1],
                    inner_z[1],
                    texture_u[1],
                    texture_v[1],
                    texture_u[2],
                    texture_v[2],
                    texture_u[2],
                    texture_v[2],
                    texture_u[1],
                    texture_v[1]
                )
            end
            if
                (y == h - 1 and fragment_state[x] == 0 and fragment_times[x] > 0)
                or (fragment_state[(w + 1) * (y + 1) + x] == 0 and fragment_times[(w + 1) * (y + 1) + x] > 0)
            then
                push_quad(
                    outer_x[2],
                    outer_y[2],
                    outer_z[2],
                    outer_x[3],
                    outer_y[3],
                    outer_z[3],
                    inner_x[3],
                    inner_y[3],
                    inner_z[3],
                    inner_x[2],
                    inner_y[2],
                    inner_z[2],
                    texture_u[2],
                    texture_v[2],
                    texture_u[3],
                    texture_v[3],
                    texture_u[3],
                    texture_v[3],
                    texture_u[2],
                    texture_v[2]
                )
            end
            if
                (x == 0 and fragment_state[(w + 1) * y + w - 1] == 0 and fragment_times[(w + 1) * y + w - 1] > 0)
                or (fragment_state[(w + 1) * y + x - 1] == 0 and fragment_times[(w + 1) * y + x - 1] > 0)
            then
                push_quad(
                    outer_x[3],
                    outer_y[3],
                    outer_z[3],
                    outer_x[0],
                    outer_y[0],
                    outer_z[0],
                    inner_x[0],
                    inner_y[0],
                    inner_z[0],
                    inner_x[3],
                    inner_y[3],
                    inner_z[3],
                    texture_u[3],
                    texture_v[3],
                    texture_u[0],
                    texture_v[0],
                    texture_u[0],
                    texture_v[0],
                    texture_u[3],
                    texture_v[3]
                )
            end
        end
    end
end
flush_vertices()
