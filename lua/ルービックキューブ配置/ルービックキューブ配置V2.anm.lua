--label:${ROOT_CATEGORY}\変形
--group:基本,true

---$select:配置
---配置1=1
---配置2=2
---配置3=3
local select_layout = 1

---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_size = 100

---$track:間隔(%)
---min=-1000
---max=1000
---step=0.1
local track_interval_percent = 10

--group:回転手順,false

---$string:事前回転位置
local pre_rotation_layers = ""

---$string:事前回転方向
local pre_rotation_directions = ""

---$string:回転位置
local rotation_layers = "1251"

---$string:回転方向
local rotation_directions = "0010"

--group:表示,false

---$check:内部表示
local check_show_internal_faces = true

--group:

local function rotate_point(component_1, component_2, rotation_sine, rotation_cosine)
    return component_1 * rotation_cosine + component_2 * rotation_sine,
        -component_1 * rotation_sine + component_2 * rotation_cosine
end

if check_show_internal_faces == nil then
    check_show_internal_faces = true
end
local rotation_layer_sequence = rotation_layers or "0"
local rotation_direction_sequence = rotation_directions or "0"
local pre_rotation_layer_sequence = pre_rotation_layers or ""
local pre_rotation_direction_sequence = pre_rotation_directions or ""

local surface_x0 = {}
local surface_y0 = {}
local surface_z0 = {}
local surface_x1 = {}
local surface_y1 = {}
local surface_z1 = {}
local surface_x2 = {}
local surface_y2 = {}
local surface_z2 = {}
local surface_x3 = {}
local surface_y3 = {}
local surface_z3 = {}
local rotation_steps = {}
local cube_x = {}
local cube_y = {}
local cube_z = {}
local u0 = {}
local u1 = {}
local u2 = {}
local u3 = {}
local v0 = {}
local v1 = {}
local v2 = {}
local v3 = {}

local cube_size = track_size
local cube_spacing = cube_size * (1 + track_interval_percent / 100)

local instruction_count = math.min(string.len(rotation_layer_sequence), string.len(rotation_direction_sequence))
for rotation_step_index = 1, instruction_count do
    rotation_steps[rotation_step_index] =
        tonumber(string.sub(rotation_layer_sequence, rotation_step_index, rotation_step_index))
    if tonumber(string.sub(rotation_direction_sequence, rotation_step_index, rotation_step_index)) == 1 then
        rotation_steps[rotation_step_index] = -rotation_steps[rotation_step_index]
    end
end
local frames_per_rotation = (obj.totalframe + 1) / instruction_count
local current_rotation_index = math.floor(obj.frame / frames_per_rotation)
local first_rotation_index = 1

instruction_count = math.min(string.len(pre_rotation_layer_sequence), string.len(pre_rotation_direction_sequence))
if instruction_count > 0 then
    for rotation_step_index = 1, instruction_count do
        rotation_steps[rotation_step_index - instruction_count] =
            tonumber(string.sub(pre_rotation_layer_sequence, rotation_step_index, rotation_step_index))
        if tonumber(string.sub(pre_rotation_direction_sequence, rotation_step_index, rotation_step_index)) == 1 then
            rotation_steps[rotation_step_index - instruction_count] =
                -rotation_steps[rotation_step_index - instruction_count]
        end
    end
    first_rotation_index = 1 - instruction_count
end

local width, height = obj.w, obj.h
local third_width = width / 3
local third_height = height / 3
local ninth_width = width / 9
local sixth_height = height / 6

for face_index = 0, 5 do
    u0[face_index], v0[face_index] = 0, 0
    u1[face_index], v1[face_index] = width, 0
    u2[face_index], v2[face_index] = width, height
    u3[face_index], v3[face_index] = 0, height
end

for i = -1, 1 do
    for j = -1, 1 do
        for k = -1, 1 do
            if select_layout == 1 then
                u0[0], v0[0] = (i + 1) * third_width, (j + 1) * third_height
                u1[0], v1[0] = (i + 2) * third_width, (j + 1) * third_height
                u2[0], v2[0] = (i + 2) * third_width, (j + 2) * third_height
                u3[0], v3[0] = (i + 1) * third_width, (j + 2) * third_height

                u0[1], v0[1] = (k + 1) * third_width, (j + 1) * third_height
                u1[1], v1[1] = (k + 2) * third_width, (j + 1) * third_height
                u2[1], v2[1] = (k + 2) * third_width, (j + 2) * third_height
                u3[1], v3[1] = (k + 1) * third_width, (j + 2) * third_height

                u0[2], v0[2] = (1 - i) * third_width, (j + 1) * third_height
                u1[2], v1[2] = (2 - i) * third_width, (j + 1) * third_height
                u2[2], v2[2] = (2 - i) * third_width, (j + 2) * third_height
                u3[2], v3[2] = (1 - i) * third_width, (j + 2) * third_height

                u0[3], v0[3] = (1 - k) * third_width, (j + 1) * third_height
                u1[3], v1[3] = (2 - k) * third_width, (j + 1) * third_height
                u2[3], v2[3] = (2 - k) * third_width, (j + 2) * third_height
                u3[3], v3[3] = (1 - k) * third_width, (j + 2) * third_height

                u0[4], v0[4] = (i + 1) * third_width, (1 - k) * third_height
                u1[4], v1[4] = (i + 2) * third_width, (1 - k) * third_height
                u2[4], v2[4] = (i + 2) * third_width, (2 - k) * third_height
                u3[4], v3[4] = (i + 1) * third_width, (2 - k) * third_height

                u0[5], v0[5] = (i + 1) * third_width, (k + 1) * third_height
                u1[5], v1[5] = (i + 2) * third_width, (k + 1) * third_height
                u2[5], v2[5] = (i + 2) * third_width, (k + 2) * third_height
                u3[5], v3[5] = (i + 1) * third_width, (k + 2) * third_height
            elseif select_layout == 3 then
                u0[0], v0[0] = (i + 1) * ninth_width, (j + 1) * sixth_height
                u1[0], v1[0] = (i + 2) * ninth_width, (j + 1) * sixth_height
                u2[0], v2[0] = (i + 2) * ninth_width, (j + 2) * sixth_height
                u3[0], v3[0] = (i + 1) * ninth_width, (j + 2) * sixth_height

                u0[1], v0[1] = (3 + k + 1) * ninth_width, (j + 1) * sixth_height
                u1[1], v1[1] = (3 + k + 2) * ninth_width, (j + 1) * sixth_height
                u2[1], v2[1] = (3 + k + 2) * ninth_width, (j + 2) * sixth_height
                u3[1], v3[1] = (3 + k + 1) * ninth_width, (j + 2) * sixth_height

                u0[2], v0[2] = (1 - i) * ninth_width, (j + 1 + 3) * sixth_height
                u1[2], v1[2] = (2 - i) * ninth_width, (j + 1 + 3) * sixth_height
                u2[2], v2[2] = (2 - i) * ninth_width, (j + 2 + 3) * sixth_height
                u3[2], v3[2] = (1 - i) * ninth_width, (j + 2 + 3) * sixth_height

                u0[3], v0[3] = (3 + 1 - k) * ninth_width, (j + 1 + 3) * sixth_height
                u1[3], v1[3] = (3 + 2 - k) * ninth_width, (j + 1 + 3) * sixth_height
                u2[3], v2[3] = (3 + 2 - k) * ninth_width, (j + 2 + 3) * sixth_height
                u3[3], v3[3] = (3 + 1 - k) * ninth_width, (j + 2 + 3) * sixth_height

                u0[4], v0[4] = (6 + i + 1) * ninth_width, (1 - k) * sixth_height
                u1[4], v1[4] = (6 + i + 2) * ninth_width, (1 - k) * sixth_height
                u2[4], v2[4] = (6 + i + 2) * ninth_width, (2 - k) * sixth_height
                u3[4], v3[4] = (6 + i + 1) * ninth_width, (2 - k) * sixth_height

                u0[5], v0[5] = (6 + i + 1) * ninth_width, (k + 1 + 3) * sixth_height
                u1[5], v1[5] = (6 + i + 2) * ninth_width, (k + 1 + 3) * sixth_height
                u2[5], v2[5] = (6 + i + 2) * ninth_width, (k + 2 + 3) * sixth_height
                u3[5], v3[5] = (6 + i + 1) * ninth_width, (k + 2 + 3) * sixth_height
            end

            for cube_coordinate_x = -1, 1 do
                for cube_coordinate_y = -1, 1 do
                    for cube_coordinate_z = -1, 1 do
                        cube_x[9 * (cube_coordinate_x + 1) + 3 * (cube_coordinate_y + 1) + (cube_coordinate_z + 1)] =
                            cube_coordinate_x
                        cube_y[9 * (cube_coordinate_x + 1) + 3 * (cube_coordinate_y + 1) + (cube_coordinate_z + 1)] =
                            cube_coordinate_y
                        cube_z[9 * (cube_coordinate_x + 1) + 3 * (cube_coordinate_y + 1) + (cube_coordinate_z + 1)] =
                            cube_coordinate_z
                    end -- sk
                end -- sj
            end -- si

            local min_x = -cube_size / 2 + cube_spacing * i
            local max_x = cube_size / 2 + cube_spacing * i
            local min_y = -cube_size / 2 + cube_spacing * j
            local max_y = cube_size / 2 + cube_spacing * j
            local min_z = -cube_size / 2 + cube_spacing * k
            local max_z = cube_size / 2 + cube_spacing * k

            surface_x0[0] = min_x
            surface_y0[0] = min_y
            surface_z0[0] = min_z
            surface_x1[0] = max_x
            surface_y1[0] = min_y
            surface_z1[0] = min_z
            surface_x2[0] = max_x
            surface_y2[0] = max_y
            surface_z2[0] = min_z
            surface_x3[0] = min_x
            surface_y3[0] = max_y
            surface_z3[0] = min_z
            surface_x0[1] = max_x
            surface_y0[1] = min_y
            surface_z0[1] = min_z
            surface_x1[1] = max_x
            surface_y1[1] = min_y
            surface_z1[1] = max_z
            surface_x2[1] = max_x
            surface_y2[1] = max_y
            surface_z2[1] = max_z
            surface_x3[1] = max_x
            surface_y3[1] = max_y
            surface_z3[1] = min_z
            surface_x0[2] = max_x
            surface_y0[2] = min_y
            surface_z0[2] = max_z
            surface_x1[2] = min_x
            surface_y1[2] = min_y
            surface_z1[2] = max_z
            surface_x2[2] = min_x
            surface_y2[2] = max_y
            surface_z2[2] = max_z
            surface_x3[2] = max_x
            surface_y3[2] = max_y
            surface_z3[2] = max_z
            surface_x0[3] = min_x
            surface_y0[3] = min_y
            surface_z0[3] = max_z
            surface_x1[3] = min_x
            surface_y1[3] = min_y
            surface_z1[3] = min_z
            surface_x2[3] = min_x
            surface_y2[3] = max_y
            surface_z2[3] = min_z
            surface_x3[3] = min_x
            surface_y3[3] = max_y
            surface_z3[3] = max_z
            surface_x0[4] = min_x
            surface_y0[4] = min_y
            surface_z0[4] = max_z
            surface_x1[4] = max_x
            surface_y1[4] = min_y
            surface_z1[4] = max_z
            surface_x2[4] = max_x
            surface_y2[4] = min_y
            surface_z2[4] = min_z
            surface_x3[4] = min_x
            surface_y3[4] = min_y
            surface_z3[4] = min_z
            surface_x0[5] = min_x
            surface_y0[5] = max_y
            surface_z0[5] = min_z
            surface_x1[5] = max_x
            surface_y1[5] = max_y
            surface_z1[5] = min_z
            surface_x2[5] = max_x
            surface_y2[5] = max_y
            surface_z2[5] = max_z
            surface_x3[5] = min_x
            surface_y3[5] = max_y
            surface_z3[5] = max_z

            for rotation_step_index = first_rotation_index, current_rotation_index + 1 do
                local signed_action, rotation_angle, action, angle_cosine, angle_sine, rotation_direction

                if rotation_step_index <= current_rotation_index then
                    signed_action = rotation_steps[rotation_step_index]
                    rotation_angle = math.pi / 2
                    action = math.floor(math.abs(signed_action)) --0, 1,2,3, 4,5,6, 7,8,9
                    if signed_action < 0 then
                        rotation_angle = -rotation_angle
                    end
                    angle_cosine = math.cos(rotation_angle)
                    angle_sine = math.sin(-rotation_angle)
                else
                    signed_action = rotation_steps[current_rotation_index + 1]
                    local rotation_angle = math.pi
                        / 2
                        * (obj.frame - current_rotation_index * frames_per_rotation)
                        / frames_per_rotation
                    action = math.floor(math.abs(signed_action)) --0, 1,2,3, 4,5,6, 7,8,9
                    if signed_action < 0 then
                        rotation_angle = -rotation_angle
                    end
                    angle_cosine = math.cos(rotation_angle)
                    angle_sine = math.sin(-rotation_angle)
                end

                if signed_action > 0 then
                    rotation_direction = -1
                else
                    rotation_direction = 1
                end

                if action == 1 or action == 2 or action == 3 then
                    if cube_z[9 * (i + 1) + 3 * (j + 1) + (k + 1)] == action - 2 then
                        for face_index = 0, 5 do
                            surface_x0[face_index], surface_y0[face_index] =
                                rotate_point(surface_x0[face_index], surface_y0[face_index], angle_sine, angle_cosine)
                            surface_x1[face_index], surface_y1[face_index] =
                                rotate_point(surface_x1[face_index], surface_y1[face_index], angle_sine, angle_cosine)
                            surface_x2[face_index], surface_y2[face_index] =
                                rotate_point(surface_x2[face_index], surface_y2[face_index], angle_sine, angle_cosine)
                            surface_x3[face_index], surface_y3[face_index] =
                                rotate_point(surface_x3[face_index], surface_y3[face_index], angle_sine, angle_cosine)
                        end
                        cube_x[9 * (i + 1) + 3 * (j + 1) + (k + 1)], cube_y[9 * (i + 1) + 3 * (j + 1) + (k + 1)] =
                            rotate_point(
                                cube_x[9 * (i + 1) + 3 * (j + 1) + (k + 1)],
                                cube_y[9 * (i + 1) + 3 * (j + 1) + (k + 1)],
                                rotation_direction,
                                0
                            )
                    end
                end

                if action == 4 or action == 5 or action == 6 then
                    if cube_x[9 * (i + 1) + 3 * (j + 1) + (k + 1)] == action - 5 then
                        for face_index = 0, 5 do
                            surface_y0[face_index], surface_z0[face_index] =
                                rotate_point(surface_y0[face_index], surface_z0[face_index], angle_sine, angle_cosine)
                            surface_y1[face_index], surface_z1[face_index] =
                                rotate_point(surface_y1[face_index], surface_z1[face_index], angle_sine, angle_cosine)
                            surface_y2[face_index], surface_z2[face_index] =
                                rotate_point(surface_y2[face_index], surface_z2[face_index], angle_sine, angle_cosine)
                            surface_y3[face_index], surface_z3[face_index] =
                                rotate_point(surface_y3[face_index], surface_z3[face_index], angle_sine, angle_cosine)
                        end
                        cube_y[9 * (i + 1) + 3 * (j + 1) + (k + 1)], cube_z[9 * (i + 1) + 3 * (j + 1) + (k + 1)] =
                            rotate_point(
                                cube_y[9 * (i + 1) + 3 * (j + 1) + (k + 1)],
                                cube_z[9 * (i + 1) + 3 * (j + 1) + (k + 1)],
                                rotation_direction,
                                0
                            )
                    end
                end

                if action == 7 or action == 8 or action == 9 then
                    if cube_y[9 * (i + 1) + 3 * (j + 1) + (k + 1)] == action - 8 then
                        for face_index = 0, 5 do
                            surface_z0[face_index], surface_x0[face_index] =
                                rotate_point(surface_z0[face_index], surface_x0[face_index], angle_sine, angle_cosine)
                            surface_z1[face_index], surface_x1[face_index] =
                                rotate_point(surface_z1[face_index], surface_x1[face_index], angle_sine, angle_cosine)
                            surface_z2[face_index], surface_x2[face_index] =
                                rotate_point(surface_z2[face_index], surface_x2[face_index], angle_sine, angle_cosine)
                            surface_z3[face_index], surface_x3[face_index] =
                                rotate_point(surface_z3[face_index], surface_x3[face_index], angle_sine, angle_cosine)
                        end
                        cube_z[9 * (i + 1) + 3 * (j + 1) + (k + 1)], cube_x[9 * (i + 1) + 3 * (j + 1) + (k + 1)] =
                            rotate_point(
                                cube_z[9 * (i + 1) + 3 * (j + 1) + (k + 1)],
                                cube_x[9 * (i + 1) + 3 * (j + 1) + (k + 1)],
                                rotation_direction,
                                0
                            )
                    end
                end

                if rotation_step_index == current_rotation_index + 1 then
                    if not check_show_internal_faces then
                        for face_index = 0, 5 do
                            if
                                (face_index == 0 and k == -1)
                                or (face_index == 2 and k == 1)
                                or (face_index == 1 and i == 1)
                                or (face_index == 3 and i == -1)
                                or (face_index == 4 and j == -1)
                                or (face_index == 5 and j == 1)
                            then
                                obj.drawpoly(
                                    surface_x0[face_index],
                                    surface_y0[face_index],
                                    surface_z0[face_index],
                                    surface_x1[face_index],
                                    surface_y1[face_index],
                                    surface_z1[face_index],
                                    surface_x2[face_index],
                                    surface_y2[face_index],
                                    surface_z2[face_index],
                                    surface_x3[face_index],
                                    surface_y3[face_index],
                                    surface_z3[face_index],
                                    u0[face_index],
                                    v0[face_index],
                                    u1[face_index],
                                    v1[face_index],
                                    u2[face_index],
                                    v2[face_index],
                                    u3[face_index],
                                    v3[face_index]
                                )
                            end
                        end -- s
                    else
                        for face_index = 0, 5 do
                            obj.drawpoly(
                                surface_x0[face_index],
                                surface_y0[face_index],
                                surface_z0[face_index],
                                surface_x1[face_index],
                                surface_y1[face_index],
                                surface_z1[face_index],
                                surface_x2[face_index],
                                surface_y2[face_index],
                                surface_z2[face_index],
                                surface_x3[face_index],
                                surface_y3[face_index],
                                surface_z3[face_index],
                                u0[face_index],
                                v0[face_index],
                                u1[face_index],
                                v1[face_index],
                                u2[face_index],
                                v2[face_index],
                                u3[face_index],
                                v3[face_index]
                            )
                        end -- s
                    end -- sho
                end -- if n
            end -- n
        end -- k
    end -- j
end -- i
