--label:${ROOT_CATEGORY}\カメラ制御
---$track:ターゲット
---min=1
---max=100
---step=0.01
local track_target_index = 1

---$track:カメラ距離
---min=0
---max=20000
---step=0.1
local track_camera_distance = 1024

---$track:イーズ
---min=0
---max=100
---step=0.1
local track_easing = 20

---$check:なめらか
local check_smooth = true

---$select:指定方法
---絶対値=0
---カメラからの相対値=1
---前ターゲットからの相対値=2
local select_target_method = 0

--group:ターゲット指定

---$value:ターゲット一覧
local target_layers = {}

---$track:ターゲット1
---min=0
---max=1000
---step=1
local track_target_layer_1 = 0

---$track:ターゲット2
---min=0
---max=1000
---step=1
local track_target_layer_2 = 0

---$track:ターゲット3
---min=0
---max=1000
---step=1
local track_target_layer_3 = 0

---$track:ターゲット4
---min=0
---max=1000
---step=1
local track_target_layer_4 = 0

---$track:ターゲット5
---min=0
---max=1000
---step=1
local track_target_layer_5 = 0

---$track:ターゲット6
---min=0
---max=1000
---step=1
local track_target_layer_6 = 0

---$track:ターゲット7
---min=0
---max=1000
---step=1
local track_target_layer_7 = 0

---$track:ターゲット8
---min=0
---max=1000
---step=1
local track_target_layer_8 = 0

---$track:ターゲット9
---min=0
---max=1000
---step=1
local track_target_layer_9 = 0

---$track:ターゲット10
---min=0
---max=1000
---step=1
local track_target_layer_10 = 0

local get_value_type = function(value)
    local string_value = tostring(value)
    if string_value == value then
        return "string"
    end
    if string_value == "nil" then
        return "nil"
    end
    if string_value == "true" or string_value == "false" then
        return "boolean"
    end
    if string.find(string_value, "table:") then
        return "table"
    end
    if string.find(string_value, "function:") then
        return "function"
    end
    if string.find(string_value, "userdata:") then
        return "userdata"
    end
    return "number"
end

local function is_enabled(value)
    return value == true or value == 1
end

select_target_method = math.floor(select_target_method)

local resolved_target_layers = {}
local target_count
if #target_layers > 0 then
    resolved_target_layers = target_layers
    target_count = #resolved_target_layers
else
    resolved_target_layers = {
        track_target_layer_1,
        track_target_layer_2,
        track_target_layer_3,
        track_target_layer_4,
        track_target_layer_5,
        track_target_layer_6,
        track_target_layer_7,
        track_target_layer_8,
        track_target_layer_9,
        track_target_layer_10,
    }
    target_count = 10
    for i = 1, 10 do
        if get_value_type(resolved_target_layers[i]) ~= "number" then
            target_count = i - 1
            break
        end
    end
end

local target_position = track_target_index
local track_camera_distance = track_camera_distance
local easing_strength = track_easing / 10
if target_position > target_count then
    target_position = target_count
end

if select_target_method == 1 then
    for i = 1, target_count do
        resolved_target_layers[i] = resolved_target_layers[i] + obj.layer
    end
elseif select_target_method == 2 then
    local cumulative_layer = obj.layer
    for i = 1, target_count do
        cumulative_layer = cumulative_layer + resolved_target_layers[i]
        resolved_target_layers[i] = cumulative_layer
    end
end

local target_data = {}
for i = 1, target_count do
    resolved_target_layers[i] = math.floor(resolved_target_layers[i])
    if resolved_target_layers[i] < 1 then
        resolved_target_layers[i] = 1
    end
    target_data[i] = {
        x = obj.getvalue("layer" .. resolved_target_layers[i] .. ".x"),
        y = obj.getvalue("layer" .. resolved_target_layers[i] .. ".y"),
        z = obj.getvalue("layer" .. resolved_target_layers[i] .. ".z"),
        rx = obj.getvalue("layer" .. resolved_target_layers[i] .. ".rx"),
        ry = obj.getvalue("layer" .. resolved_target_layers[i] .. ".ry"),
        rz = obj.getvalue("layer" .. resolved_target_layers[i] .. ".rz"),
    }
end
for i = target_count, 1, -1 do
    if target_data[i].x == nil then
        table.remove(target_data, i)
        target_count = target_count - 1
    end
end

local current_target_index = math.floor(target_position)
local next_target_index = current_target_index + 1
target_position = target_position - current_target_index

if easing_strength ~= 0 then
    target_position = math.exp(easing_strength * (2 * target_position - 1))
    local easing_coefficient = (math.exp(easing_strength) + 1) / (math.exp(easing_strength) - 1)
    target_position = (1 + easing_coefficient * (target_position - 1) / (target_position + 1)) / 2
end
local inverse_target_fraction = 1 - target_position
if next_target_index > target_count then
    next_target_index = target_count
end

local camera = obj.getoption("camera_param")

local target_rotation_x, target_rotation_y, target_rotation_z

if not is_enabled(check_smooth) then
    camera.tx = inverse_target_fraction * target_data[current_target_index].x
        + target_position * target_data[next_target_index].x
    camera.ty = inverse_target_fraction * target_data[current_target_index].y
        + target_position * target_data[next_target_index].y
    camera.tz = inverse_target_fraction * target_data[current_target_index].z
        + target_position * target_data[next_target_index].z

    target_rotation_x = inverse_target_fraction * target_data[current_target_index].rx
        + target_position * target_data[next_target_index].rx
    target_rotation_y = inverse_target_fraction * target_data[current_target_index].ry
        + target_position * target_data[next_target_index].ry
    target_rotation_z = inverse_target_fraction * target_data[current_target_index].rz
        + target_position * target_data[next_target_index].rz
else
    local previous_target_index = current_target_index - 1
    if previous_target_index < 1 then
        previous_target_index = 1
    end
    local following_target_index = next_target_index + 1
    if following_target_index > target_count then
        following_target_index = target_count
    end

    local x0, y0, z0 =
        target_data[previous_target_index].x, target_data[previous_target_index].y, target_data[previous_target_index].z
    local x1, y1, z1 =
        target_data[current_target_index].x, target_data[current_target_index].y, target_data[current_target_index].z
    local x2, y2, z2 =
        target_data[next_target_index].x, target_data[next_target_index].y, target_data[next_target_index].z
    local x3, y3, z3 =
        target_data[following_target_index].x,
        target_data[following_target_index].y,
        target_data[following_target_index].z
    camera.tx, camera.ty, camera.tz = obj.interpolation(target_position, x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3)

    x0, y0, z0 =
        target_data[previous_target_index].rx,
        target_data[previous_target_index].ry,
        target_data[previous_target_index].rz
    x1, y1, z1 =
        target_data[current_target_index].rx, target_data[current_target_index].ry, target_data[current_target_index].rz
    x2, y2, z2 = target_data[next_target_index].rx, target_data[next_target_index].ry, target_data[next_target_index].rz
    x3, y3, z3 =
        target_data[following_target_index].rx,
        target_data[following_target_index].ry,
        target_data[following_target_index].rz
    target_rotation_x, target_rotation_y, target_rotation_z =
        obj.interpolation(target_position, x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3)
end

local rotation_x_sine = math.sin(target_rotation_x * math.pi / 180)
local rotation_x_cosine = math.cos(target_rotation_x * math.pi / 180)
local rotation_y_sine = math.sin(target_rotation_y * math.pi / 180)
local rotation_y_cosine = math.cos(target_rotation_y * math.pi / 180)
local rotation_z_sine = math.sin(target_rotation_z * math.pi / 180)
local rotation_z_cosine = math.cos(target_rotation_z * math.pi / 180)

local camera_direction_x = -rotation_y_sine
local camera_direction_y = rotation_x_sine * rotation_y_cosine
local camera_direction_z = -rotation_x_cosine * rotation_y_cosine

local up_vector_x = rotation_y_cosine * rotation_z_sine
local up_vector_y = -rotation_x_cosine * rotation_z_cosine + (rotation_x_sine * rotation_z_sine) * rotation_y_sine
local up_vector_z = -rotation_x_sine * rotation_z_cosine - (rotation_x_cosine * rotation_z_sine) * rotation_y_sine

camera.x = camera.tx + camera_direction_x * track_camera_distance
camera.y = camera.ty + camera_direction_y * track_camera_distance
camera.z = camera.tz + camera_direction_z * track_camera_distance
camera.ux = up_vector_x
camera.uy = up_vector_y
camera.uz = up_vector_z

obj.setoption("camera_param", camera)
