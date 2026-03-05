local OldScript = function(track0, track1, track2, track3, check0, Ct, rv, Gr, loadmap, mapnum, limap, spt, seed)
    local Roty = function(y0, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
        local m01 = -cos_y * sin_z
        local m11 = cos_x * cos_z - sin_x * sin_z * sin_y
        local m21 = sin_x * cos_z + cos_x * sin_z * sin_y
        return m01 * y0, m11 * y0, m21 * y0
    end

    local Rotx = function(x0, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
        local m00 = cos_y * cos_z
        local m10 = cos_x * sin_z + sin_x * cos_z * sin_y
        local m20 = sin_x * sin_z - cos_x * cos_z * sin_y
        return m00 * x0, m10 * x0, m20 * x0
    end

    local makeSpl = function(SI, spt)
        local drawSpl = function(paz_x, paz_y, HB2, HB4)
            obj.setoption("drawtarget", "tempbuffer", HB4, HB4)
            for i = 1, 6 do
                obj.drawpoly(
                    -paz_x[i],
                    paz_y[i],
                    0,
                    paz_x[i],
                    paz_y[i],
                    0,
                    paz_x[i + 1],
                    paz_y[i + 1],
                    0,
                    -paz_x[i + 1],
                    paz_y[i + 1],
                    0
                )
                obj.drawpoly(
                    -paz_x[i],
                    -paz_y[i],
                    0,
                    paz_x[i],
                    -paz_y[i],
                    0,
                    paz_x[i + 1],
                    -paz_y[i + 1],
                    0,
                    -paz_x[i + 1],
                    -paz_y[i + 1],
                    0
                )
            end
            obj.drawpoly(-paz_x[7], paz_y[7], 0, paz_x[7], paz_y[7], 0, paz_x[7], -paz_y[7], 0, -paz_x[7], -paz_y[7], 0)
            obj.drawpoly(paz_x[7], paz_y[7], 0, paz_x[8], paz_y[8], 0, paz_x[8], -paz_y[8], 0, paz_x[7], -paz_y[7], 0)
            obj.drawpoly(
                -paz_x[7],
                paz_y[7],
                0,
                -paz_x[8],
                paz_y[8],
                0,
                -paz_x[8],
                -paz_y[8],
                0,
                -paz_x[7],
                -paz_y[7],
                0
            )
            obj.drawpoly(paz_x[8], paz_y[8], 0, HB2, paz_y[8], 0, HB2, -paz_y[8], 0, paz_x[8], -paz_y[8], 0)
            obj.drawpoly(-paz_x[8], paz_y[8], 0, -HB2, paz_y[8], 0, -HB2, -paz_y[8], 0, -paz_x[8], -paz_y[8], 0)
        end

        local paz_x, paz_y
        local se = 2
        local d = 1
        local bai = SI / 240 * se
        local HB = 100 * bai
        local HB2 = HB * 2
        local HB4 = HB * 4

        obj.load("figure", "四角形", 0xffffff, HB2)
        obj.setoption("blend", "alpha_add")

        --一回り小さい
        paz_x = { 9 * bai, 35 * bai, 43 * bai, 43 * bai, 27 * bai, 27 * bai, 35 * bai, 120 * bai }
        paz_y = { 200 * bai, 191 * bai, 176 * bai, 155 * bai, 128 * bai, 120 * bai, 113 * bai, 120 * bai }
        drawSpl(paz_x, paz_y, HB2, HB4)
        obj.copybuffer("cache:SPC", "tmp")

        --普通サイズ
        paz_x = { 9 * bai, 35 * bai, 43 * bai - d, 43 * bai - d, 27 * bai - d, 27 * bai - d, 35 * bai, 120 * bai }
        paz_y = { 200 * bai - d, 191 * bai - d, 176 * bai, 155 * bai, 128 * bai, 120 * bai, 113 * bai - d, 120 * bai }
        drawSpl(paz_x, paz_y, HB2, HB4)
        obj.copybuffer("obj", "cache:SPC")

        obj.setoption("blend", "alpha_sub")
        obj.draw(SI * se, 0, 0, 1, 1, 0, 0, 90)
        obj.draw(-SI * se, 0, 0, 1, 1, 0, 0, 90)

        obj.copybuffer("obj", "tmp")
        obj.effect("縁取り", "サイズ", spt, "ぼかし", 0)
        local w2, h2 = obj.getpixel()
        obj.setoption("drawtarget", "tempbuffer", w2 * 0.5, h2 * 0.5)
        obj.setoption("blend", 0)
        obj.draw(0, 0, 0, 1 / se)
        obj.copybuffer("cache:PC", "tmp")
    end

    local makepzz = function(nx, ny, SI, Bw2, Bh2, rv, T, Ps, j1, rot, zoom, seed)
        if (nx % 2) == 1 then
            j1 = 1 - j1
        end
        local j2 = 1 - j1
        obj.copybuffer("tmp", "cache:ORI")
        obj.copybuffer("obj", "cache:PC")
        obj.setoption("blend", "alpha_sub")
        for j = -ny, ny do
            for i = -nx + ((j + j1) % 2), nx, 2 do
                obj.draw(i * SI, j * SI, 0, 1, 1, 0, 0, rot)
            end
        end
        obj.copybuffer("obj", "tmp")

        obj.setoption("drawtarget", "framebuffer")
        obj.setoption("blend", 0)

        local SI = SI * zoom
        local Bw2 = Bw2 * zoom
        local Bh2 = Bh2 * zoom

        for j = -ny, ny do
            local yy = SI * j
            for i = -nx + ((j + j2) % 2), nx, 2 do
                local x0, x1, x2, x3
                local y0, y1, y2, y3
                local z0, z1, z2, z3

                local xx = SI * i

                local itix = xx + Bw2
                local itiy = yy + Bh2

                local u0, v0 = itix, itiy - SI
                local u1, v1 = itix + SI, itiy
                local u2, v2 = itix, itiy + SI
                local u3, v3 = itix - SI, itiy

                local r1 = obj.rand(-100, 100, i + nx, j + ny + 1000 + seed) * 0.01 * T[i][j] * rv
                local r2 = obj.rand(-100, 100, i + nx, j + ny + 2000 + seed) * 0.01 * T[i][j] * rv
                local r3 = obj.rand(-100, 100, i + nx, j + ny + 3000 + seed) * 0.01 * T[i][j] * rv
                local sin_x = math.sin(r1)
                local cos_x = math.cos(r1)
                local sin_y = math.sin(r2)
                local cos_y = math.cos(r2)
                local sin_z = math.sin(r3)
                local cos_z = math.cos(r3)

                x0, y0, z0 = Roty(-SI, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
                x1, y1, z1 = Rotx(SI, sin_x, cos_x, sin_y, cos_y, sin_z, cos_z)
                x2, y2, z2 = -x0, -y0, -z0
                x3, y3, z3 = -x1, -y1, -z1

                itix = xx + Ps[i][j].x
                itiy = yy + Ps[i][j].y
                itiz = Ps[i][j].z

                x0, x1, x2, x3 = x0 + itix, x1 + itix, x2 + itix, x3 + itix
                y0, y1, y2, y3 = y0 + itiy, y1 + itiy, y2 + itiy, y3 + itiy
                z0, z1, z2, z3 = z0 + itiz, z1 + itiz, z2 + itiz, z3 + itiz

                obj.drawpoly(x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, u0, v0, u1, v1, u2, v2, u3, v3)
            end
        end
    end

    local GmakeMapData = function(mapnum, nx, ny, T)
        if mapnum >= 1 and mapnum <= 5 then
            local Tcal = ({
                function(i, j, RR)
                    return math.sqrt(i * i + j * j) / RR
                end, --円
                function(i, j, RR)
                    return math.max(math.abs(i), math.abs(j)) / RR
                end, --四角
                function(i, j, RR)
                    return math.max(math.abs(i - j), math.abs(i + j)) / RR
                end, --斜め四角
                function(i, j, RR)
                    return math.min(math.abs(i), math.abs(j)) / RR
                end, --十字
                function(i, j, RR)
                    return math.min(math.abs(i - j), math.abs(i + j)) / RR
                end, --斜め十字
            })[mapnum]

            local RR = ({ math.sqrt(nx * nx + ny * ny), math.max(nx, ny), nx + ny, math.min(nx, ny), math.max(nx, ny) })[mapnum]

            for i = -nx, nx do
                T[i] = {}
                for j = -ny, ny do
                    T[i][j] = Tcal(i, j, RR)
                end
            end
        else
            local RR = (2 * nx + 1) * (2 * ny + 1)
            local k = 0
            for i = -nx, nx do
                T[i] = {}
                for j = -ny, ny do
                    T[i][j] = k / RR
                    k = k + 1
                end
            end
            for i = -nx, nx do
                for j = -ny, ny do
                    local ii = obj.rand(-nx, nx, i + nx, j + ny + seed)
                    local jj = obj.rand(-ny, ny, i + nx, j + ny + seed + 100000)
                    T[i][j], T[ii][jj] = T[ii][jj], T[i][j]
                end
            end
        end
    end

    local GmakeMapDataF = function(mapnum, nx, ny, T)
        extbuffer.read(mapnum)
        local w, h = obj.getpixel()

        obj.pixeloption("type", "yc")
        obj.pixeloption("get", "obj")

        for i = -nx, nx do
            T[i] = {}
            for j = -ny, ny do
                local yi, cbi, cri, ai =
                    obj.getpixel((w - 1) * (i + nx) / (2 * nx), (h - 1) * (j + ny) / (2 * ny), "yc")
                T[i][j] = yi / 4096
            end
        end
    end

    local zoom = obj.getvalue("zoom") * 0.01

    local CKFN1 = io.open(obj.getinfo("script_path") .. "extbuffer.lua", "r")
    local CKFN2 = io.open(obj.getinfo("script_path") .. "extbuffer_core.dll", "r")
    if CKFN1 and CKFN2 then
        require("extbuffer")
    end

    obj.setanchor("Ct", 1)
    local apt = track0 * 0.01
    local Vs = track1 * 7.5
    local dir = -math.rad(track2)

    rv = rv * 0.03
    Gr[1] = Gr[1] * 30
    Gr[2] = Gr[2] * 30
    Gr[3] = Gr[3] * 30

    limap = limap * 0.01

    local SI = math.floor(track3)
    local w, h = obj.getpixel()
    local nx = math.floor((w / SI + 1) * 0.5)
    local ny = math.floor((h / SI + 1) * 0.5)
    local Bw, Bh = (2 * nx + 2) * SI, (2 * ny + 2) * SI
    local Bw2, Bh2 = Bw * 0.5, Bh * 0.5

    obj.setoption("drawtarget", "tempbuffer", Bw, Bh)
    obj.draw()
    obj.copybuffer("cache:ORI", "tmp")

    --ピース作成
    makeSpl(SI, spt)

    --マップ作成
    local T = {}
    if loadmap == 0 then
        GmakeMapData(mapnum, nx, ny, T)
    else
        GmakeMapDataF(mapnum, nx, ny, T)
    end

    if check0 then
        for i = -nx, nx do
            for j = -ny, ny do
                T[i][j] = 1 - T[i][j]
            end
        end
    end

    for i = -nx, nx do
        for j = -ny, ny do
            local t
            if T[i][j] <= limap then
                t = -T[i][j] + apt
                T[i][j] = math.max(t, 0)
            else
                T[i][j] = 0
            end
        end
    end

    --軌道作成
    Ps = {}
    for i = -nx, nx do
        Ps[i] = {}
        local ii = i - Ct[1] / SI
        for j = -ny, ny do
            local t = T[i][j]

            local jj = j - Ct[2] / SI
            local rad = dir * math.sqrt(ii * ii + jj * jj) / ny
            local v1 = -Vs * math.sin(rad)
            local v2 = Vs * math.cos(rad)
            rad = math.atan2(ii, jj)

            local Vx = v1 * math.sin(rad)
            local Vy = v1 * math.cos(rad)
            local Vz = -v2

            Ps[i][j] = {}
            Ps[i][j].x = (Gr[1] * t * t * 0.5 + Vx * t) * zoom
            Ps[i][j].y = (Gr[2] * t * t * 0.5 + Vy * t) * zoom
            Ps[i][j].z = (Gr[3] * t * t * 0.5 + Vz * t) * zoom
        end
    end

    --表示
    makepzz(nx, ny, SI, Bw2, Bh2, rv, T, Ps, 1, 0, zoom, seed)
    obj.setoption("drawtarget", "tempbuffer")
    makepzz(nx, ny, SI, Bw2, Bh2, rv, T, Ps, 0, -90, zoom, seed)
end
