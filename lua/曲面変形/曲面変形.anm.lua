--label:${ROOT_CATEGORY}\変形
---$track:変形1
---min=-100
---max=100
---step=0.1
local track_deform_1 = 25

---$track:変形2
---min=-100
---max=100
---step=0.1
local track_deform_2 = 25

---$track:個数
---min=0
---max=10000
---step=1
local track_object_count = 0

---$track:分割数
---min=1
---max=300
---step=1
local track_division_count = 8

---$track:領域サイズX
---min=1
---max=50000
---step=1
local track_area_size_x = 2000

---$track:領域サイズY
---min=1
---max=50000
---step=1
local track_area_size_y = 2000

---$track:領域サイズZ
---min=1
---max=50000
---step=1
local track_area_size_z = 2000

---$track:移動速度
---min=0
---max=1000
---step=0.1
local track_move_speed = 100

---$track:移動方向誤差
---min=0
---max=90
---step=0.1
local track_move_direction_error = 12

---$track:回転速度
---min=0
---max=100
---step=0.1
local track_rotation_speed = 10

---$check:重心を中心にする
local check_center_on_centroid = false

local set_3d_image = function(n, w, h, max_horizontal_angle, max_vertical_angle, rx, ry, rz, cx, cy, cz)
    local rotate_xyz = function(x, y, z, rx, ry, rz)
        local sin_x = math.sin(rx)
        local cos_x = math.cos(rx)
        local sin_y = math.sin(ry)
        local cos_y = math.cos(ry)
        local sin_z = math.sin(rz)
        local cos_z = math.cos(rz)
        local m00 = cos_y * cos_z
        local m01 = -cos_y * sin_z
        local m02 = -sin_y
        local m10 = cos_x * sin_z - sin_x * sin_y * cos_z
        local m11 = cos_x * cos_z + sin_x * sin_y * sin_z
        local m12 = -sin_x * cos_y
        local m20 = sin_x * sin_z + cos_x * sin_y * cos_z
        local m21 = sin_x * cos_z - cos_x * sin_y * sin_z
        local m22 = cos_x * cos_y

        local xx = m00 * x + m01 * y + m02 * z
        local yy = m10 * x + m11 * y + m12 * z
        local zz = m20 * x + m21 * y + m22 * z

        return xx, yy, zz
    end

    local e_x = 2 * max_horizontal_angle / w
    local e_y = 2 * max_vertical_angle / h

    local half_divisions = math.max(1, math.floor(n / 2))
    local x = {}
    local y = {}
    local z = {}
    local u = {}
    local v = {}
    local gz = 0

    for i = 0, half_divisions do
        local th = i / half_divisions * max_horizontal_angle
        local xx, zz
        if e_x ~= 0 then
            xx = math.sin(th) / e_x
            zz = (1 - math.cos(th)) / e_x
        else
            xx = i / half_divisions * w / 2
            zz = 0
        end

        x[i] = {}
        y[i] = {}
        z[i] = {}
        u[i] = {}
        v[i] = {}
        x[-i] = {}
        y[-i] = {}
        z[-i] = {}
        u[-i] = {}
        v[-i] = {}

        if e_y ~= 0 then
            for j = 0, n do
                local jj = j / n - 0.5
                local th2 = 2 * jj * max_vertical_angle
                local yy2, rr2
                yy2 = math.sin(th2) / e_y
                rr2 = (1 - math.cos(th2)) / e_y
                x[i][j] = xx - rr2 * math.sin(th)
                y[i][j] = yy2
                z[i][j] = zz + rr2 * math.cos(th)
                x[-i][j] = -x[i][j]
                y[-i][j] = y[i][j]
                z[-i][j] = z[i][j]
                gz = gz + z[i][j]
            end
        else
            for j = 0, n do
                x[i][j] = xx
                y[i][j] = (j / n - 0.5) * h
                z[i][j] = zz
                x[-i][j] = -xx
                y[-i][j] = y[i][j]
                z[-i][j] = zz
                gz = gz + z[i][j]
            end
        end
        for j = 0, n do
            u[i][j] = (1 + i / half_divisions) * obj.w / 2
            v[i][j] = j / n * obj.h
            u[-i][j] = (half_divisions - i) / half_divisions * obj.w / 2
            v[-i][j] = v[i][j]
        end
    end

    if check_center_on_centroid then
        gz = gz / ((half_divisions + 1) * (n + 1))
    else
        gz = 0
    end

    for i = -half_divisions, half_divisions do
        for j = 0, n do
            local xx, yy, zz = rotate_xyz(x[i][j], y[i][j], z[i][j] - gz, rx, ry, rz)

            x[i][j] = xx + cx
            y[i][j] = yy + cy
            z[i][j] = zz + cz
        end
    end

    local vertices = {}
    for i = -half_divisions, half_divisions - 1 do
        for j = 0, n - 1 do
            vertices[#vertices + 1] = {
                x[i][j],
                y[i][j],
                z[i][j],
                x[i + 1][j],
                y[i + 1][j],
                z[i + 1][j],
                x[i + 1][j + 1],
                y[i + 1][j + 1],
                z[i + 1][j + 1],
                x[i][j + 1],
                y[i][j + 1],
                z[i][j + 1],
                u[i][j],
                v[i][j],
                u[i + 1][j],
                v[i + 1][j],
                u[i + 1][j + 1],
                v[i + 1][j + 1],
                u[i][j + 1],
                v[i][j + 1],
            }
        end
    end
    if #vertices > 0 then
        obj.drawpoly(vertices)
    end
end

local w, h = obj.getpixel()
w = w * obj.getvalue("zoom") * 0.01
h = h * obj.getvalue("zoom") * 0.01
local division_count = math.max(1, track_division_count or 8)
local area_size_x = math.max(1, track_area_size_x or 2000)
local area_size_y = math.max(1, track_area_size_y or 2000)
local area_size_z = math.max(1, track_area_size_z or 2000)
local move_speed = track_move_speed or 100
local move_direction_error = math.max(10, 100 - (track_move_direction_error or 12))
local rotation_speed = track_rotation_speed or 10
local max_horizontal_angle = math.pi * track_deform_1 * 0.01
local max_vertical_angle = math.pi * track_deform_2 * 0.01
local object_count = track_object_count

local t = obj.time

if object_count == 0 then
    set_3d_image(division_count, w, h, max_horizontal_angle, max_vertical_angle, 0, 0, 0, 0, 0, 0)
else
    for i = 1, object_count do
        local rx = obj.rand(0, 360, i, 1000) + rotation_speed * t * obj.rand(0, 1000, i, 7000) * 0.001
        local ry = obj.rand(0, 360, i, 2000) + rotation_speed * t * obj.rand(0, 1000, i, 8000) * 0.001
        local rz = obj.rand(0, 360, i, 3000) + rotation_speed * t * obj.rand(0, 1000, i, 9000) * 0.001

        local div_vx = move_speed * obj.rand(move_direction_error, 100, i, 10000) * 0.01
        local dvyz = math.sqrt(move_speed * move_speed - div_vx * div_vx)
        local radi = math.rad(obj.rand(0, 3600, i, 11000) * 0.1)
        local div_vy = dvyz * math.cos(radi)
        local div_vz = dvyz * math.sin(radi)

        local cx = (obj.rand(0, area_size_x, i, 4000) + div_vx * t) % area_size_x - area_size_x * 0.5
        local cy = obj.rand(0, area_size_y, i, 5000) + div_vy * t - area_size_y * 0.5
        local cz = obj.rand(0, area_size_z, i, 6000) + div_vz * t

        set_3d_image(
            division_count,
            w,
            h,
            max_horizontal_angle,
            max_vertical_angle,
            math.rad(rx),
            math.rad(ry),
            math.rad(rz),
            cx,
            cy,
            cz
        )
    end
end
