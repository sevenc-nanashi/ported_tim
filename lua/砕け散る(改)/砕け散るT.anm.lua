--label:${ROOT_CATEGORY}\アニメーション効果
---$track:粉砕度
---min=0
---max=5000
---track_playback_speed=0.1
local track_shatter_amount = 100

---$track:時間差
---min=0
---max=1000
---track_playback_speed=0.1
local track_time_offset = 100

---$track:限界半径
---min=-10000
---max=10000
---track_playback_speed=0.1
local track_radius = 300

---$track:厚さ
---min=0
---max=1000
---track_playback_speed=0.1
local track_thickness = 20

---$track:破片サイズ
---min=1
---max=500
---track_playback_speed=0.1
local track_piece_size = 50

---$track:ランダム形状
---min=0
---max=100
---track_playback_speed=0.1
local track_shape_randomness_percent = 100

---$track:中心X
---min=-2000
---max=2000
---track_playback_speed=0.1
local track_center_x = 0

---$track:中心Y
---min=-2000
---max=2000
---track_playback_speed=0.1
local track_center_y = 0

---$track:中心Z
---min=-2000
---max=2000
---track_playback_speed=0.1
local track_center_z = 0

---$track:速度
---min=-1000
---max=1000
---track_playback_speed=0.1
local track_speed = 100

---$track:重力
---min=-1000
---max=1000
---track_playback_speed=0.1
local track_gravity = 100

---$track:距離影響
---min=0
---max=500
---track_playback_speed=0.1
local track_distance_influence = 100

---$track:ランダム回転
---min=0
---max=500
---track_playback_speed=0.1
local track_random_rotation = 100

---$track:ランダム方向
---min=0
---max=500
---track_playback_speed=0.1
local track_direction_randomness = 100

---$track:再生速度
---min=0
---max=10
---track_playback_speed=0.01
local track_playback_speed = 1.0

local grid_x = {}
local grid_y = {}
local px = {}
local py = {}
local pz = {}
local qx = {}
local qy = {}
local qz = {}
local pu = {}
local pv = {}
local piece_states = {}
local start_times = {}

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

local time = track_playback_speed * track_shatter_amount / 1000
local delay = track_time_offset
local radius_limit = track_radius
local thickness = track_thickness
obj.effect()
track_gravity = track_gravity * 6
delay = delay * 0.002
track_distance_influence = track_distance_influence * 0.2
track_random_rotation = math.floor(track_random_rotation * 10)
track_direction_randomness = track_direction_randomness / 80
if track_piece_size < 10 then
    track_piece_size = 10
end
track_shape_randomness_percent = math.abs(track_shape_randomness_percent)
if track_shape_randomness_percent >= 100 then
    track_shape_randomness_percent = 100
end
local source_width = obj.w
local source_height = obj.h
local speed_scale = track_speed * 0.01 * math.sqrt(track_distance_influence)
local width_count = math.floor(source_width / track_piece_size)
local height_count = math.floor(source_height / track_piece_size)
local diagonal = math.sqrt(source_width * source_width + source_height * source_height)
if width_count < 2 then
    width_count = 2
elseif width_count > source_width then
    width_count = source_width
end
if height_count < 2 then
    height_count = 2
elseif height_count > source_height then
    height_count = source_height
end
local position_error_x = source_width / width_count * 0.43 * track_shape_randomness_percent / 100
local position_error_y = source_height / height_count * 0.43 * track_shape_randomness_percent / 100

for y = 0, height_count do
    for x = 0, width_count do
        grid_x[(width_count + 1) * y + x] = source_width * x / width_count
            + obj.rand(-position_error_x, position_error_x, x, y)
        grid_y[(width_count + 1) * y + x] = source_height * y / height_count
            + obj.rand(-position_error_y, position_error_y, x, y + 1000)
    end
end
for y = 0, height_count do
    grid_x[(width_count + 1) * y] = 0
    grid_x[(width_count + 1) * y + width_count] = source_width
end
for x = 0, width_count do
    grid_y[x] = 0
    grid_y[(width_count + 1) * height_count + x] = source_height
end

for y = 0, height_count - 1 do
    local offset_y = source_height * (y + 0.5) / height_count - track_center_y - source_height / 2
    for x = 0, width_count - 1 do
        local n0 = (width_count + 1) * y + x
        local n1 = (width_count + 1) * (y + 1) + x

        local gx = (grid_x[n0] + grid_x[n0 + 1] + grid_x[n1 + 1] + grid_x[n1]) / 4
        local gy = (grid_y[n0] + grid_y[n0 + 1] + grid_y[n1 + 1] + grid_y[n1]) / 4

        local center_x = gx - source_width / 2
        local center_y = gy - source_height / 2

        local velocity_x = center_x - track_center_x
        local velocity_y = center_y - track_center_y
        local velocity_z = -track_center_z
        local distance = math.sqrt(velocity_x * velocity_x + velocity_y * velocity_y + velocity_z * velocity_z)

        start_times[(width_count + 1) * y + x] = time - distance / diagonal * delay

        local radius = math.sqrt(
            (source_width * (x + 0.5) / width_count - track_center_x - source_width / 2) ^ 2
                + offset_y * offset_y
                + track_center_z * track_center_z
        )
        piece_states[(width_count + 1) * y + x] = 0
        if
            (radius_limit >= 0 and radius >= radius_limit + track_piece_size)
            or (radius_limit < 0 and radius < -radius_limit - track_piece_size)
        then
            piece_states[(width_count + 1) * y + x] = 2
        elseif (radius_limit >= 0 and radius >= radius_limit) or (radius_limit < 0 and radius < -radius_limit) then
            piece_states[(width_count + 1) * y + x] = 1
        end
    end
end

for y = 0, height_count - 1 do
    for x = 0, width_count - 1 do
        local state = piece_states[(width_count + 1) * y + x]
        local n0 = (width_count + 1) * y + x
        local n1 = (width_count + 1) * (y + 1) + x
        pu[0] = grid_x[n0]
        pu[1] = grid_x[n0 + 1]
        pu[2] = grid_x[n1 + 1]
        pu[3] = grid_x[n1]
        pv[0] = grid_y[n0]
        pv[1] = grid_y[n0 + 1]
        pv[2] = grid_y[n1 + 1]
        pv[3] = grid_y[n1]
        -- 基準の計算
        local gx = (pu[0] + pu[1] + pu[2] + pu[3]) / 4
        local gy = (pv[0] + pv[1] + pv[2] + pv[3]) / 4

        local center_x = gx - source_width / 2
        local center_y = gy - source_height / 2

        local velocity_x = center_x - track_center_x
        local velocity_y = center_y - track_center_y
        local velocity_z = -track_center_z
        local velocity_factor = math.sqrt(velocity_x * velocity_x + velocity_y * velocity_y + velocity_z * velocity_z)

        local current_time = start_times[(width_count + 1) * y + x]

        if (current_time < 0) or state ~= 0 then
            current_time = 0
        end

        velocity_factor = 1 / (1 + velocity_factor * velocity_factor / (diagonal * diagonal) * track_distance_influence)
        velocity_x = velocity_x * velocity_factor
            + obj.rand(-track_piece_size, track_piece_size, x, y + 4000) * track_direction_randomness
        velocity_y = velocity_y * velocity_factor
            + obj.rand(-track_piece_size, track_piece_size, x, y + 5000) * track_direction_randomness
        velocity_z = velocity_z * velocity_factor
            + obj.rand(-track_piece_size, track_piece_size, x, y + 6000) * track_direction_randomness
        center_x = center_x + current_time * velocity_x * speed_scale
        center_y = center_y + current_time * velocity_y * speed_scale + current_time * current_time * track_gravity
        local center_z = current_time * velocity_z * speed_scale

        -- 回転を計算
        local rotation_x = current_time * obj.rand(-track_random_rotation, track_random_rotation, x, y + 2000) / 100
        local rotation_y = current_time * obj.rand(-track_random_rotation, track_random_rotation, x, y + 3000) / 100
        local rotation_z = current_time * obj.rand(-track_random_rotation, track_random_rotation, x, y + 4000) / 100
        local sin_x = math.sin(rotation_x)
        local cos_x = math.cos(rotation_x)
        local sin_y = math.sin(rotation_y)
        local cos_y = math.cos(rotation_y)
        local sin_z = math.sin(rotation_z)
        local cos_z = math.cos(rotation_z)
        local m00 = cos_y * cos_z
        local m01 = -cos_y * sin_z
        local m02 = -sin_y
        local m10 = cos_x * sin_z - sin_x * sin_y * cos_z
        local m11 = cos_x * cos_z + sin_x * sin_y * sin_z
        local m12 = -sin_x * cos_y
        local m20 = sin_x * sin_z + cos_x * sin_y * cos_z
        local m21 = sin_x * cos_z - cos_x * sin_y * sin_z
        local m22 = cos_x * cos_y

        for i = 0, 3 do
            rotation_x = pu[i] - gx
            rotation_y = pv[i] - gy
            px[i] = m00 * rotation_x + m01 * rotation_y
            py[i] = m10 * rotation_x + m11 * rotation_y
            pz[i] = m20 * rotation_x + m21 * rotation_y
        end

        for i = 0, 3 do
            px[i] = px[i] + center_x
            py[i] = py[i] + center_y
            pz[i] = pz[i] + center_z
            qx[i] = px[i] + m02 * thickness
            qy[i] = py[i] + m12 * thickness
            qz[i] = pz[i] + m22 * thickness
        end
        push_quad(
            px[0],
            py[0],
            pz[0],
            px[1],
            py[1],
            pz[1],
            px[2],
            py[2],
            pz[2],
            px[3],
            py[3],
            pz[3],
            pu[0],
            pv[0],
            pu[1],
            pv[1],
            pu[2],
            pv[2],
            pu[3],
            pv[3]
        )
        push_quad(
            qx[0],
            qy[0],
            qz[0],
            qx[1],
            qy[1],
            qz[1],
            qx[2],
            qy[2],
            qz[2],
            qx[3],
            qy[3],
            qz[3],
            pu[0],
            pv[0],
            pu[1],
            pv[1],
            pu[2],
            pv[2],
            pu[3],
            pv[3]
        )
        if state == 0 and current_time > 0 then
            push_quad(
                px[0],
                py[0],
                pz[0],
                px[1],
                py[1],
                pz[1],
                qx[1],
                qy[1],
                qz[1],
                qx[0],
                qy[0],
                qz[0],
                pu[0],
                pv[0],
                pu[1],
                pv[1],
                pu[1],
                pv[1],
                pu[0],
                pv[0]
            )
            push_quad(
                px[1],
                py[1],
                pz[1],
                px[2],
                py[2],
                pz[2],
                qx[2],
                qy[2],
                qz[2],
                qx[1],
                qy[1],
                qz[1],
                pu[1],
                pv[1],
                pu[2],
                pv[2],
                pu[2],
                pv[2],
                pu[1],
                pv[1]
            )
            push_quad(
                px[2],
                py[2],
                pz[2],
                px[3],
                py[3],
                pz[3],
                qx[3],
                qy[3],
                qz[3],
                qx[2],
                qy[2],
                qz[2],
                pu[2],
                pv[2],
                pu[3],
                pv[3],
                pu[3],
                pv[3],
                pu[2],
                pv[2]
            )
            push_quad(
                px[3],
                py[3],
                pz[3],
                px[0],
                py[0],
                pz[0],
                qx[0],
                qy[0],
                qz[0],
                qx[3],
                qy[3],
                qz[3],
                pu[3],
                pv[3],
                pu[0],
                pv[0],
                pu[0],
                pv[0],
                pu[3],
                pv[3]
            )
        elseif state == 1 then
            if
                y == 0
                or (
                    piece_states[(width_count + 1) * (y - 1) + x] == 0
                    and start_times[(width_count + 1) * (y - 1) + x] > 0
                )
            then
                push_quad(
                    px[0],
                    py[0],
                    pz[0],
                    px[1],
                    py[1],
                    pz[1],
                    qx[1],
                    qy[1],
                    qz[1],
                    qx[0],
                    qy[0],
                    qz[0],
                    pu[0],
                    pv[0],
                    pu[1],
                    pv[1],
                    pu[1],
                    pv[1],
                    pu[0],
                    pv[0]
                )
            end
            if
                x == width_count - 1
                or (piece_states[(width_count + 1) * y + x + 1] == 0 and start_times[(width_count + 1) * y + x + 1] > 0)
            then
                push_quad(
                    px[1],
                    py[1],
                    pz[1],
                    px[2],
                    py[2],
                    pz[2],
                    qx[2],
                    qy[2],
                    qz[2],
                    qx[1],
                    qy[1],
                    qz[1],
                    pu[1],
                    pv[1],
                    pu[2],
                    pv[2],
                    pu[2],
                    pv[2],
                    pu[1],
                    pv[1]
                )
            end
            if
                y == height_count - 1
                or (
                    piece_states[(width_count + 1) * (y + 1) + x] == 0
                    and start_times[(width_count + 1) * (y + 1) + x] > 0
                )
            then
                push_quad(
                    px[2],
                    py[2],
                    pz[2],
                    px[3],
                    py[3],
                    pz[3],
                    qx[3],
                    qy[3],
                    qz[3],
                    qx[2],
                    qy[2],
                    qz[2],
                    pu[2],
                    pv[2],
                    pu[3],
                    pv[3],
                    pu[3],
                    pv[3],
                    pu[2],
                    pv[2]
                )
            end
            if
                x == 0
                or (piece_states[(width_count + 1) * y + x - 1] == 0 and start_times[(width_count + 1) * y + x - 1] > 0)
            then
                push_quad(
                    px[3],
                    py[3],
                    pz[3],
                    px[0],
                    py[0],
                    pz[0],
                    qx[0],
                    qy[0],
                    qz[0],
                    qx[3],
                    qy[3],
                    qz[3],
                    pu[3],
                    pv[3],
                    pu[0],
                    pv[0],
                    pu[0],
                    pv[0],
                    pu[3],
                    pv[3]
                )
            end
        elseif (radius_limit >= 0 and state == 2) or (radius_limit < 0 and state == 0 and current_time == 0) then
            if x == 0 then
                push_quad(
                    px[3],
                    py[3],
                    pz[3],
                    px[0],
                    py[0],
                    pz[0],
                    qx[0],
                    qy[0],
                    qz[0],
                    qx[3],
                    qy[3],
                    qz[3],
                    pu[3],
                    pv[3],
                    pu[0],
                    pv[0],
                    pu[0],
                    pv[0],
                    pu[3],
                    pv[3]
                )
            elseif x == width_count - 1 then
                push_quad(
                    px[1],
                    py[1],
                    pz[1],
                    px[2],
                    py[2],
                    pz[2],
                    qx[2],
                    qy[2],
                    qz[2],
                    qx[1],
                    qy[1],
                    qz[1],
                    pu[1],
                    pv[1],
                    pu[2],
                    pv[2],
                    pu[2],
                    pv[2],
                    pu[1],
                    pv[1]
                )
            end
            if y == 0 then
                push_quad(
                    px[0],
                    py[0],
                    pz[0],
                    px[1],
                    py[1],
                    pz[1],
                    qx[1],
                    qy[1],
                    qz[1],
                    qx[0],
                    qy[0],
                    qz[0],
                    pu[0],
                    pv[0],
                    pu[1],
                    pv[1],
                    pu[1],
                    pv[1],
                    pu[0],
                    pv[0]
                )
            elseif y == height_count - 1 then
                push_quad(
                    px[2],
                    py[2],
                    pz[2],
                    px[3],
                    py[3],
                    pz[3],
                    qx[3],
                    qy[3],
                    qz[3],
                    qx[2],
                    qy[2],
                    qz[2],
                    pu[2],
                    pv[2],
                    pu[3],
                    pv[3],
                    pu[3],
                    pv[3],
                    pu[2],
                    pv[2]
                )
            end
        end
    end
end
flush_vertices()
