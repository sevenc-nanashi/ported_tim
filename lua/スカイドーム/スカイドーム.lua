--label:${ROOT_CATEGORY}\変形\@スカイドーム

---$track:水平回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$track:垂直回転
---min=-3600
---max=3600
---step=0.1
local track_rotation_2 = 0

---$track:側方回転
---min=-3600
---max=3600
---step=0.1
local track_rotation_3 = 0

---$check:親カメラデータを使用
local check_use_parent_camera = false

---$track:視野角
---min=0
---max=120
---step=0.1
local track_fov = 30

---$track:分割数
---min=1
---max=300
---step=1
local division_count = 30

---$check:描画処理
local check_additive_blend = 1

--hide@track_fov:check_use_parent_camera==1

local change_rotation_position = function(t, f)
    f = -f + math.pi
    return math.sin(f) * math.sin(t), -math.cos(t), -math.cos(f) * math.sin(t)
end

local rotate = function(x, y, z, t, f, roll)
    local sin_tilt = math.sin(t)
    local cos_tilt = math.cos(t)
    local sin_pan = math.sin(f)
    local cos_pan = math.cos(f)
    local sin_roll = math.sin(roll)
    local cos_roll = math.cos(roll)
    local rotated_zx = cos_pan * z + sin_pan * x
    local x0 = cos_pan * x - sin_pan * z
    local y0 = cos_tilt * y + sin_tilt * rotated_zx
    local z0 = -sin_tilt * y + cos_tilt * rotated_zx
    x0, y0 = cos_roll * x0 - sin_roll * y0, sin_roll * x0 + cos_roll * y0
    return x0, y0, z0
end

local intersects_screen = function(ix0, iy0, ix1, iy1, ix2, iy2, ix3, iy3, half_screen_width, half_screen_height)
    local abs = math.abs
    local poshantei = function(half_screen_width, half_screen_height, ix0, iy0, ix1, iy1, ix2, iy2, ix3, iy3)
        local winding_score = 0
        if
            (ix0 - half_screen_width) * (iy1 - half_screen_height)
                - (iy0 - half_screen_height) * (ix1 - half_screen_width)
            > 0
        then
            winding_score = winding_score + 1
        else
            winding_score = winding_score - 1
        end
        if
            (ix1 - half_screen_width) * (iy2 - half_screen_height)
                - (iy1 - half_screen_height) * (ix2 - half_screen_width)
            > 0
        then
            winding_score = winding_score + 1
        else
            winding_score = winding_score - 1
        end
        if
            (ix2 - half_screen_width) * (iy3 - half_screen_height)
                - (iy2 - half_screen_height) * (ix3 - half_screen_width)
            > 0
        then
            winding_score = winding_score + 1
        else
            winding_score = winding_score - 1
        end
        if
            (ix3 - half_screen_width) * (iy0 - half_screen_height)
                - (iy3 - half_screen_height) * (ix0 - half_screen_width)
            > 0
        then
            winding_score = winding_score + 1
        else
            winding_score = winding_score - 1
        end
        return (winding_score == 4 or winding_score == -4)
    end

    if
        (abs(ix0) <= half_screen_width and abs(iy0) <= half_screen_height)
        or (abs(ix1) <= half_screen_width and abs(iy1) <= half_screen_height)
        or (abs(ix2) <= half_screen_width and abs(iy2) <= half_screen_height)
        or (abs(ix3) <= half_screen_width and abs(iy3) <= half_screen_height)
    then
        return true
    else
        local contains_corner = poshantei(half_screen_width, half_screen_height, ix0, iy0, ix1, iy1, ix2, iy2, ix3, iy3)
        contains_corner = contains_corner
            or poshantei(-half_screen_width, half_screen_height, ix0, iy0, ix1, iy1, ix2, iy2, ix3, iy3)
        contains_corner = contains_corner
            or poshantei(half_screen_width, -half_screen_height, ix0, iy0, ix1, iy1, ix2, iy2, ix3, iy3)
        return contains_corner
            or poshantei(-half_screen_width, -half_screen_height, ix0, iy0, ix1, iy1, ix2, iy2, ix3, iy3)
    end
end

if T_SKYDOME_HORIZONTAL_RATIO == nil then
    T_SKYDOME_HORIZONTAL_RATIO = 1
    T_SKYDOME_VERTICAL_RATIO = 1
end

local projection_distance, roll, camera_tilt, camera_pan

if check_use_parent_camera then
    local camera_direction_x, camera_direction_y, camera_direction_z
    projection_distance = T_AVIUTL_CAMERA_PARAM_COPY.d

    camera_direction_x = T_AVIUTL_CAMERA_PARAM_COPY.x - T_AVIUTL_CAMERA_PARAM_COPY.tx
    camera_direction_y = T_AVIUTL_CAMERA_PARAM_COPY.y - T_AVIUTL_CAMERA_PARAM_COPY.ty
    camera_direction_z = T_AVIUTL_CAMERA_PARAM_COPY.z - T_AVIUTL_CAMERA_PARAM_COPY.tz

    local horizontal_distance = camera_direction_x * camera_direction_x + camera_direction_z * camera_direction_z
    local camera_distance = math.sqrt(camera_direction_y * camera_direction_y + horizontal_distance)
    horizontal_distance = math.sqrt(horizontal_distance)

    local camera_up_x = T_AVIUTL_CAMERA_PARAM_COPY.ux
    local camera_up_y = T_AVIUTL_CAMERA_PARAM_COPY.uy
    local camera_up_z = T_AVIUTL_CAMERA_PARAM_COPY.uz

    if horizontal_distance == 0 then
        camera_pan = 0
        if camera_direction_y > 0 then
            camera_tilt = -math.pi * 0.5
            roll = math.atan2(camera_up_x, camera_up_z) + math.pi
        else
            camera_tilt = math.pi * 0.5
            roll = -math.atan2(camera_up_x, camera_up_z)
        end
    else
        local sin_camera_pan, cos_camera_pan, sin_camera_tilt, cos_camera_tilt
        camera_pan = math.atan2(-camera_direction_x, -camera_direction_z) --水平
        camera_tilt = math.atan2(-camera_direction_y, horizontal_distance) --垂直

        sin_camera_pan = -camera_direction_x / horizontal_distance
        cos_camera_pan = -camera_direction_z / horizontal_distance
        sin_camera_tilt = -camera_direction_y / camera_distance
        cos_camera_tilt = horizontal_distance / camera_distance

        local rotated_up_x, rotated_up_y, rotated_up_z

        rotated_up_x = cos_camera_pan * camera_up_x - sin_camera_pan * camera_up_z
        rotated_up_y = cos_camera_tilt * camera_up_y
            - sin_camera_tilt * (sin_camera_pan * camera_up_x + cos_camera_pan * camera_up_z)

        local rotated_up_length = math.sqrt(rotated_up_x * rotated_up_x + rotated_up_y * rotated_up_y)
        rotated_up_x, rotated_up_y = rotated_up_x / rotated_up_length, rotated_up_y / rotated_up_length

        local dot_product = math.max(math.min(1, -rotated_up_y), -1)
        roll = math.acos(dot_product)

        if rotated_up_x > 0 then
            roll = -roll
        end
    end

    roll = roll + math.rad(T_AVIUTL_CAMERA_PARAM_COPY.rz + track_rotation_3)
else
    roll = math.rad(track_rotation_3)
    projection_distance = obj.screen_h * 0.5 / math.tan(math.rad(track_fov * 0.5))
    camera_tilt = 0
    camera_pan = 0
end

local w, h = obj.getpixel()

local texture_cell_width = w / division_count
local texture_cell_height = h / division_count
local half_division_count = division_count * 0.5
local longitude_step = math.pi / half_division_count * T_SKYDOME_HORIZONTAL_RATIO
local latitude_step = math.pi / division_count
local half_pi = math.pi * 0.5
local half_screen_width = obj.screen_w * 0.5
local half_screen_height = obj.screen_h * 0.5

local effective_tilt = math.rad(track_rotation_2) - camera_tilt
local effective_pan = -math.rad(track_rotation) + camera_pan

obj.setoption("drawtarget", "tempbuffer", obj.screen_w, obj.screen_h)
if check_additive_blend == 1 then
    obj.setoption("blend", "alpha_add")
else
    obj.setoption("blend", 0)
end

local vertices = {}

for i = 0, division_count - 1 do
    local u1 = i * texture_cell_width
    local u2 = u1 + texture_cell_width
    local f1 = (i - half_division_count) * longitude_step
    local f2 = f1 + longitude_step

    local v1 = 0 * texture_cell_height
    local t1 = (0 * latitude_step - half_pi) * T_SKYDOME_VERTICAL_RATIO + half_pi

    local x0, y0, z0 = change_rotation_position(t1, f1)
    local x1, y1, z1 = change_rotation_position(t1, f2)
    x0, y0, z0 = rotate(x0, y0, z0, effective_tilt, effective_pan, roll)
    x1, y1, z1 = rotate(x1, y1, z1, effective_tilt, effective_pan, roll)

    for j = 1, division_count do
        local v2 = j * texture_cell_height
        local t2 = (j * latitude_step - half_pi) * T_SKYDOME_VERTICAL_RATIO + half_pi

        local x2, y2, z2 = change_rotation_position(t2, f2)
        local x3, y3, z3 = change_rotation_position(t2, f1)

        x2, y2, z2 = rotate(x2, y2, z2, effective_tilt, effective_pan, roll)
        x3, y3, z3 = rotate(x3, y3, z3, effective_tilt, effective_pan, roll)

        if z0 > 0 and z1 > 0 and z2 > 0 and z3 > 0 then
            local ix0, iy0 = projection_distance * x0 / z0, projection_distance * y0 / z0
            local ix1, iy1 = projection_distance * x1 / z1, projection_distance * y1 / z1
            local ix2, iy2 = projection_distance * x2 / z2, projection_distance * y2 / z2
            local ix3, iy3 = projection_distance * x3 / z3, projection_distance * y3 / z3

            if intersects_screen(ix0, iy0, ix1, iy1, ix2, iy2, ix3, iy3, half_screen_width, half_screen_height) then
                vertices[#vertices + 1] =
                    { ix0, iy0, 0, ix1, iy1, 0, ix2, iy2, 0, ix3, iy3, 0, u1, v1, u2, v1, u2, v2, u1, v2 }
            end
        end
        v1 = v2
        t1 = t2
        x0, y0, z0 = x3, y3, z3
        x1, y1, z1 = x2, y2, z2
    end
end
if #vertices > 0 then
    obj.drawpoly(vertices)
end
obj.load("tempbuffer")
T_SKYDOME_HORIZONTAL_RATIO = nil
T_SKYDOME_VERTICAL_RATIO = nil
