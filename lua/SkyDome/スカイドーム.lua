--label:tim2\スカイドーム.anm

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

---$track:視野角
---min=0
---max=120
---step=0.1
local track_fov = 30

---$value:分割数
local N = 30

---$check:描画処理
local chk = 1

---$check:親カメラデータを取得
local check0 = false

local chgRP = function(t, f)
    f = -f + math.pi
    return math.sin(f) * math.sin(t), -math.cos(t), -math.cos(f) * math.sin(t)
end

local ROT = function(x, y, z, t, f, drz)
    local st = math.sin(t)
    local ct = math.cos(t)
    local sf = math.sin(f)
    local cf = math.cos(f)
    local sz = math.sin(drz)
    local cz = math.cos(drz)
    local zx = cf * z + sf * x
    local x0 = cf * x - sf * z
    local y0 = ct * y + st * zx
    local z0 = -st * y + ct * zx
    x0, y0 = cz * x0 - sz * y0, sz * x0 + cz * y0
    return x0, y0, z0
end

local hantei = function(ix0, iy0, ix1, iy1, ix2, iy2, ix3, iy3, wf, hf)
    local abs = math.abs
    local poshantei = function(wf, hf, ix0, iy0, ix1, iy1, ix2, iy2, ix3, iy3)
        local dd = 0
        if (ix0 - wf) * (iy1 - hf) - (iy0 - hf) * (ix1 - wf) > 0 then
            dd = dd + 1
        else
            dd = dd - 1
        end
        if (ix1 - wf) * (iy2 - hf) - (iy1 - hf) * (ix2 - wf) > 0 then
            dd = dd + 1
        else
            dd = dd - 1
        end
        if (ix2 - wf) * (iy3 - hf) - (iy2 - hf) * (ix3 - wf) > 0 then
            dd = dd + 1
        else
            dd = dd - 1
        end
        if (ix3 - wf) * (iy0 - hf) - (iy3 - hf) * (ix0 - wf) > 0 then
            dd = dd + 1
        else
            dd = dd - 1
        end
        return (dd == 4 or dd == -4)
    end

    if
        (abs(ix0) <= wf and abs(iy0) <= hf)
        or (abs(ix1) <= wf and abs(iy1) <= hf)
        or (abs(ix2) <= wf and abs(iy2) <= hf)
        or (abs(ix3) <= wf and abs(iy3) <= hf)
    then
        return true
    else
        local cc = poshantei(wf, hf, ix0, iy0, ix1, iy1, ix2, iy2, ix3, iy3)
        cc = cc or poshantei(-wf, hf, ix0, iy0, ix1, iy1, ix2, iy2, ix3, iy3)
        cc = cc or poshantei(wf, -hf, ix0, iy0, ix1, iy1, ix2, iy2, ix3, iy3)
        return cc or poshantei(-wf, -hf, ix0, iy0, ix1, iy1, ix2, iy2, ix3, iy3)
    end
end

if T_skydoom_H == nil then
    T_skydoom_H = 1
    T_skydoom_V = 1
end

local L, drz, camt, camf

if check0 then
    local camx, camy, camz
    L = aviutl_camera_param_copy.d

    camx = aviutl_camera_param_copy.x - aviutl_camera_param_copy.tx
    camy = aviutl_camera_param_copy.y - aviutl_camera_param_copy.ty
    camz = aviutl_camera_param_copy.z - aviutl_camera_param_copy.tz

    local Rxz = camx * camx + camz * camz
    local Rxyz = math.sqrt(camy * camy + Rxz)
    local Rxz = math.sqrt(Rxz)

    ucx = aviutl_camera_param_copy.ux
    ucy = aviutl_camera_param_copy.uy
    ucz = aviutl_camera_param_copy.uz

    if Rxz == 0 then
        camf = 0
        if camy > 0 then
            camt = -math.pi * 0.5
            drz = math.atan2(ucx, ucz) + math.pi
        else
            camt = math.pi * 0.5
            drz = -math.atan2(ucx, ucz)
        end
    else
        local s1, c1, s2, c2
        camf = math.atan2(-camx, -camz) --水平
        camt = math.atan2(-camy, Rxz) --垂直

        s1 = -camx / Rxz
        c1 = -camz / Rxz
        s2 = -camy / Rxyz
        c2 = Rxz / Rxyz

        local oucx, oucy, oucz

        oucx = c1 * ucx - s1 * ucz
        oucy = c2 * ucy - s2 * (s1 * ucx + c1 * ucz)

        local l = math.sqrt(oucx * oucx + oucy * oucy)
        oucx, oucy = oucx / l, oucy / l

        naiseki = math.max(math.min(1, -oucy), -1)
        drz = math.acos(naiseki)

        if oucx > 0 then
            drz = -drz
        end
    end

    drz = drz + math.rad(aviutl_camera_param_copy.rz + track_rotation_3)
else
    drz = math.rad(track_rotation_3)
    L = obj.screen_h * 0.5 / math.tan(math.rad(track_fov * 0.5))
    camt = 0
    camf = 0
end

local w, h = obj.getpixel()

local dx = w / N
local dy = h / N
local N2 = N * 0.5
local iw2 = math.pi / N2 * T_skydoom_H
local ih2 = math.pi / N
local hpi = math.pi * 0.5
local wf = obj.screen_w * 0.5
local hf = obj.screen_h * 0.5

local dt = math.rad(track_rotation_2) - camt
local df = -math.rad(track_rotation) + camf

obj.setoption("drawtarget", "tempbuffer", obj.screen_w, obj.screen_h)
if chk == 1 then
    obj.setoption("antialias", 1)
    obj.setoption("blend", "alpha_add")
else
    obj.setoption("antialias", 0)
    obj.setoption("blend", 0)
end

for i = 0, N - 1 do
    local u1 = i * dx
    local u2 = u1 + dx
    local f1 = (i - N2) * iw2
    local f2 = f1 + iw2

    local v1 = 0 * dy
    local t1 = (0 * ih2 - hpi) * T_skydoom_V + hpi

    local x0, y0, z0 = chgRP(t1, f1)
    local x1, y1, z1 = chgRP(t1, f2)
    x0, y0, z0 = ROT(x0, y0, z0, dt, df, drz)
    x1, y1, z1 = ROT(x1, y1, z1, dt, df, drz)

    for j = 1, N do
        local v2 = j * dy
        local t2 = (j * ih2 - hpi) * T_skydoom_V + hpi

        local x2, y2, z2 = chgRP(t2, f2)
        local x3, y3, z3 = chgRP(t2, f1)

        x2, y2, z2 = ROT(x2, y2, z2, dt, df, drz)
        x3, y3, z3 = ROT(x3, y3, z3, dt, df, drz)

        if z0 > 0 and z1 > 0 and z2 > 0 and z3 > 0 then
            local ix0, iy0 = L * x0 / z0, L * y0 / z0
            local ix1, iy1 = L * x1 / z1, L * y1 / z1
            local ix2, iy2 = L * x2 / z2, L * y2 / z2
            local ix3, iy3 = L * x3 / z3, L * y3 / z3

            if hantei(ix0, iy0, ix1, iy1, ix2, iy2, ix3, iy3, wf, hf) then
                obj.drawpoly(ix0, iy0, 0, ix1, iy1, 0, ix2, iy2, 0, ix3, iy3, 0, u1, v1, u2, v1, u2, v2, u1, v2)
            end
        end
        v1 = v2
        t1 = t2
        x0, y0, z0 = x3, y3, z3
        x1, y1, z1 = x2, y2, z2
    end
end
obj.load("tempbuffer")
T_skydoom_H = nil
T_skydoom_V = nil
