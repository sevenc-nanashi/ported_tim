--label:tim2
---$track:変形1
---min=-100
---max=100
---step=0.1
local rename_me_track0 = 25

---$track:変形2
---min=-100
---max=100
---step=0.1
local rename_me_track1 = 25

---$track:個数
---min=0
---max=10000
---step=1
local rename_me_track2 = 0

---$value:分割数
local N = 8

---$value:領域サイズX
local ARX = 2000

---$value:領域サイズY
local ARY = 2000

---$value:領域サイズZ
local ARZ = 2000

---$value:移動速度
local divV = 100

---$value:移動方向誤差
local dpos = 12

---$value:回転速度
local rotV = 10

---$value:アンチエイリアス
local ANT = 0

---$check:重心を中心にする
local rename_me_check0 = true

local set3Dimg = function(N, w, h, thx_max, thy_max, rx, ry, rz, cx, cy, cz)
    local ROTxyz = function(x, y, z, rx, ry, rz)
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

    local e_x = 2 * thx_max / w
    local e_y = 2 * thy_max / h

    Nh = math.max(1, math.floor(N / 2))
    local x = {}
    local y = {}
    local z = {}
    local u = {}
    local v = {}
    local gz = 0

    for i = 0, Nh do
        local th = i / Nh * thx_max
        local xx, zz
        if e_x ~= 0 then
            xx = math.sin(th) / e_x
            zz = (1 - math.cos(th)) / e_x
        else
            xx = i / Nh * w / 2
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
            for j = 0, N do
                local jj = j / N - 0.5
                local th2 = 2 * jj * thy_max
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
            for j = 0, N do
                x[i][j] = xx
                y[i][j] = (j / N - 0.5) * h
                z[i][j] = zz
                x[-i][j] = -xx
                y[-i][j] = y[i][j]
                z[-i][j] = zz
                gz = gz + z[i][j]
            end
        end
        for j = 0, N do
            u[i][j] = (1 + i / Nh) * obj.w / 2
            v[i][j] = j / N * obj.h
            u[-i][j] = (Nh - i) / Nh * obj.w / 2
            v[-i][j] = v[i][j]
        end
    end

    if rename_me_check0 then
        gz = gz / ((Nh + 1) * (N + 1))
    else
        gz = 0
    end

    for i = -Nh, Nh do
        for j = 0, N do
            local xx, yy, zz = ROTxyz(x[i][j], y[i][j], z[i][j] - gz, rx, ry, rz)

            x[i][j] = xx + cx
            y[i][j] = yy + cy
            z[i][j] = zz + cz
        end
    end

    obj.setoption("antialias", ANT)

    for i = -Nh, Nh - 1 do
        for j = 0, N - 1 do
            obj.drawpoly(
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
                v[i][j + 1]
            )
        end
    end
end

local w, h = obj.getpixel()
w = w * obj.getvalue("zoom") * 0.01
h = h * obj.getvalue("zoom") * 0.01
dpos = math.max(100 - dpos, 10)
local thx_max = math.pi * rename_me_track0 * 0.01
local thy_max = math.pi * rename_me_track1 * 0.01
local M = rename_me_track2

local T = obj.time

if M == 0 then
    set3Dimg(N, w, h, thx_max, thy_max, 0, 0, 0, 0, 0, 0)
else
    for i = 1, M do
        local rx = obj.rand(0, 360, i, 1000) + rotV * T * obj.rand(0, 1000, i, 7000) * 0.001
        local ry = obj.rand(0, 360, i, 2000) + rotV * T * obj.rand(0, 1000, i, 8000) * 0.001
        local rz = obj.rand(0, 360, i, 3000) + rotV * T * obj.rand(0, 1000, i, 9000) * 0.001

        local divVx = divV * obj.rand(dpos, 100, i, 10000) * 0.01
        local dvyz = math.sqrt(divV * divV - divVx * divVx)
        local radi = math.rad(obj.rand(0, 3600, i, 11000) * 0.1)
        local divVy = dvyz * math.cos(radi)
        local divVz = dvyz * math.sin(radi)

        local cx = (obj.rand(0, ARX, i, 4000) + divVx * T) % ARX - ARX * 0.5
        local cy = obj.rand(0, ARY, i, 5000) + divVy * T - ARY * 0.5
        local cz = obj.rand(0, ARZ, i, 6000) + divVz * T

        set3Dimg(N, w, h, thx_max, thy_max, math.rad(rx), math.rad(ry), math.rad(rz), cx, cy, cz)
    end
end
