--label:tim2\未分類
---$track:サイズ
---min=0
---max=2000
---step=1
local track_size = 200

---$track:円形度合
---min=0
---max=100
---step=0.1
local track_roundness = 60

---$track:形状
---min=0
---max=10000
---step=1
local track_shape = 3000

---$track:展開
---min=0
---max=100
---step=0.1
local track_unfold = 100

---$color:色
local col = "0xffffff"

---$value:本体拡大率%
local Hzm = 100

---$value:飛沫数1
local wN = 5

---$value:飛沫数2
local tN = 4

---$value:飛散1幅拡大率%
local zm1 = 100

---$value:飛散2拡大率%
local zm2 = 100

---$value:飛散2歪み%
local H2as = 0

---$value:本体変化乱数
local Hseed0 = 0

---$value:飛散変化乱数1
local Hseed1 = 0

---$value:飛散変化乱数2
local Hseed2 = 0

---$check:新描画法
local NewP = 1

NewP = NewP or 0

if NewP == 1 then
    Hseed0 = math.floor(math.abs(Hseed0 or 0))
    Hseed1 = math.floor(math.abs(Hseed1 or 0))
    Hseed2 = math.floor(math.abs(Hseed2 or 0))
    Hzm = (Hzm or 100) * 0.01
    zm1 = (zm1 or 100) * 0.01
    zm2 = (zm2 or 100) * 0.01
    H2as = (H2as or 0) * 0.02

    local L = track_size
    local Cp = track_roundness * 0.01
    local Lh = L * 0.5
    local seed = track_shape
    local Dev = track_unfold * 0.01
    obj.load("figure", "四角形", col, 1)
    TH1 = {}
    TH2 = {}
    for j = 1, wN do
        TH1[j] = obj.rand(30, 60, -j - Hseed1, 10000 + seed) * 0.01
    end
    for j = 1, tN do
        TH2[j] = obj.rand(20, 80, -j - Hseed2, 11000 + seed) * 0.01
    end
    --飛散1
    local r1 = 30 * 0.5
    local w = 100 * 0.5

    local C1 = 4 * math.sqrt(0.12 * 0.12 - (0.2 - 0.12) ^ 2)
    local xc = {}
    local yc = {}
    local yd = {}
    local ye = {}
    local numc = -1

    if Dev > 0.3 then
        local r1 = r1 * zm1
        local N1 = 18
        local N2 = 102
        for i = 0, N1 - 1 do
            numc = numc + 1
            local x1 = i / N1 * 0.2
            xc[numc] = -w * (0.3 * i / N1 - 1)
            yc[numc] = r1 * 0.48 * (math.sqrt(1 - (x1 / 0.12 - 1) ^ 2))
        end
        for i = 0, N2 do
            local x1 = 0.7 * i / N2 + 0.2
            numc = numc + 1
            xc[numc] = -w * (-0.7 + 1.7 * i / N2)
            yc[numc] = r1 * (3 * (x1 - 0.2) * (x1 - 0.6) + C1)
        end
    end
    for j = 1, wN do
        if Dev > TH1[j] then
            local DD = 3 * (Dev - TH1[j])
            DD = DD > 1 and 1 or DD
            DD = DD * (2 - DD)
            local dN = math.floor(numc * (1 - DD))

            local ycc = {}
            for i = 0, dN - 1 do
                ycc[i] = 0
            end
            for i = dN, numc do
                ycc[i] = yc[i - dN]
            end
            obj.setoption("drawtarget", "tempbuffer", 2 * w, 2 * r1)
            obj.setoption("blend", "alpha_add")
            for i = 0, numc do
                local d = 0
                local e = 0
                if ycc[i] > 0 then
                    for k = 1, 3 do
                        local kk = k + Hseed1
                        d = d
                            + math.sin(
                                    obj.rand(10, 20, -kk, j + 100 + seed) * 0.1 * math.pi * i / numc
                                        + obj.rand(0, 731, -kk, j + 200 + seed) * 0.01
                                )
                                * obj.rand(30, 50, -kk, j + 300 + seed)
                    end
                    e = -d
                    for k = 1, 3 do
                        local kk = k + Hseed1
                        d = d
                            + math.sin(
                                    obj.rand(100, 150, -kk, j + 400 + seed) * 0.1 * math.pi * i / numc
                                        + obj.rand(0, 731, -kk, j + 500 + seed) * 0.01
                                )
                                * 15
                                / k
                        e = e
                            + math.cos(
                                    obj.rand(100, 150, -kk, j + 700 + seed) * 0.1 * math.pi * i / numc
                                        + obj.rand(0, 731, -kk, j + 800 + seed) * 0.01
                                )
                                * 15
                                / k
                    end
                else
                    e, d = 0, 0
                end
                yd[i] = ycc[i] + d * 0.04
                ye[i] = ycc[i] + e * 0.03
            end

            for i = 0, numc - 1 do
                if ycc[i] > 0 then
                    obj.drawpoly(xc[i], -yd[i], 0, xc[i + 1], -yd[i + 1], 0, xc[i + 1], ye[i + 1], 0, xc[i], ye[i], 0)
                end
            end
            obj.copybuffer("cache:HS1_img" .. j, "tmp")
        end
    end

    --本体
    local DD = Dev * 1.5
    DD = DD > 1 and 1 or DD
    DD = DD * (2 - DD)
    obj.setoption("drawtarget", "tempbuffer", L, L)
    obj.setoption("blend", "alpha_add")
    local RR = {}
    for i = 0, 199 do
        local ff = 0
        for k = 1, 30 do
            local Cpp = 0.2 * (1 - Cp / (1 + (k - 1) * 0.01))
            ff = ff + math.sin((math.pi * k * i + obj.rand(0, 731, -k - Hseed0, seed)) * 0.01) / k * Cpp
        end
        for k = 65, 80 do
            local Cpp = 0.15 * (1 - Cp / (1 + (k - 1) * 0.01))
            ff = ff + math.sin((math.pi * k * i + obj.rand(0, 731, -k - Hseed0, seed)) * 0.01) / k * Cpp
        end
        RR[i] = (ff * DD + 0.5) * Lh * DD * Hzm
    end
    RR[200] = RR[0]
    for i = 1, 4 do
        RR[-i] = RR[200 - i]
        RR[200 + i] = RR[i]
    end
    local r0
    local t0
    local x0, y0 = RR[0], 0
    for i = 1, 200 do
        local r1 = RR[i]
        local t1 = i * math.pi / 100
        local x1, y1 = r1 * math.cos(t1), r1 * math.sin(t1)
        obj.drawpoly(x0, y0, 0, x1, y1, 0, 0, 0, 0, 0, 0, 0)
        x0, y0 = x1, y1
    end

    --飛散1
    for i = 1, wN do
        if Dev > TH1[i] then
            local ii = i + Hseed1
            obj.copybuffer("obj", "cache:HS1_img" .. i)
            local j = (obj.rand(0, 199 / wN, -ii, 1000 + seed) + math.floor(200 * i / wN)) % 200
            local rot = j * math.pi / 100
            local p2 = obj.rand(80, 100, -ii, 3000 + seed) * 0.01
            local p3 = obj.rand(70, 90, -ii, 4000 + seed) * 0.01
            local HSL = Lh * obj.rand(25, 80, -ii, 2000 + seed) * 0.01
            local x1 = p3
                * math.min(
                    RR[j - 4],
                    RR[j - 3],
                    RR[j - 2],
                    RR[j - 1],
                    RR[j],
                    RR[j + 1],
                    RR[j + 2],
                    RR[j + 3],
                    RR[j + 4],
                    Lh - HSL
                )
            local x2 = x1 + p3 * HSL
            local y2 = p2 * HSL * r1 / w * 0.5

            local y1 = -y2
            local cos = math.cos(rot)
            local sin = math.sin(rot)
            local u0, v0 = x1 * cos - y1 * sin, x1 * sin + y1 * cos
            local u1, v1 = x2 * cos - y1 * sin, x2 * sin + y1 * cos
            local u2, v2 = x2 * cos - y2 * sin, x2 * sin + y2 * cos
            local u3, v3 = x1 * cos - y2 * sin, x1 * sin + y2 * cos
            obj.drawpoly(u0, v0, 0, u1, v1, 0, u2, v2, 0, u3, v3, 0)
            obj.load("figure", "四角形", col, 1)
            obj.drawpoly(u0, v0, 0, 0, 0, 0, 0, 0, 0, u3, v3, 0)
        end
    end

    --飛散2

    obj.load("figure", "四角形", col, 1)

    for j = 1, tN do
        if Dev > TH2[j] then
            local DD = 10 * (Dev - TH2[j])
            DD = DD > 1 and 1 or DD
            DD = DD * (2 - DD) * zm2
            local N = 20
            local jj = j + Hseed2
            local k = (obj.rand(0, 199 / tN, -jj, 8000 + seed) + math.floor(200 * j / tN)) % 200
            local rot = k * math.pi / 100
            local r0 = Lh * obj.rand(50, 85, -jj, 7000 + seed) * 0.01
            local ox, oy = r0 * math.cos(rot), r0 * math.sin(rot)
            local de = obj.rand(0, 628, -jj, 11000 + seed) * 0.01
            local siz = Lh * 0.15 * obj.rand(40, 90, -jj, 9000 + seed) * 0.01 * 0.5 * DD
            local rh = obj.rand(200, 800, -jj, 10000 + seed)
            local r = {}
            local t = {}
            for i = 0, N - 1 do
                local d = 0
                for k = 1, 3 do
                    d = d
                        + math.sin(
                                2 * k * math.pi * i / N + obj.rand(0, 731, -k - Hseed2, j + 200 + seed) * 0.01 + de
                            )
                            * obj.rand(20, 80, -k - Hseed2, j + 300 + seed)
                end
                local x = 1 - math.abs(i - N / 2) / (N / 2)
                r[i] = siz * (1 + d * 0.001) * (H2as * x * x * (x - 1) + 1) ^ 1.5
                t[i] = i * 2 * math.pi / N + rot
            end
            r[N] = r[0]
            t[N] = 0 + rot
            local x0, y0 = r[0] * math.cos(t[0]) + ox, r[0] * math.sin(t[0]) + oy
            for i = 1, N do
                local x1, y1 = r[i] * math.cos(t[i]) + ox, r[i] * math.sin(t[i]) + oy
                obj.drawpoly(x0, y0, 0, x0, y0, 0, x1, y1, 0, ox, oy, 0)
                x0, y0 = x1, y1
            end
        end
    end

    obj.load("tempbuffer")
else --ここからOLD-------
    local L = track_size
    local Cp = track_roundness * 0.01
    local Lh = L * 0.5
    local seed = track_shape
    local N = 30
    obj.load("figure", "四角形", col, 1)
    --飛散1
    local r1 = 30 * 0.5
    local w = 100 * 0.5
    local C1 = 4 * math.sqrt(0.12 * 0.12 - (0.2 - 0.12) ^ 2)
    local xc = {}
    local yc = {}
    local yd = {}
    local ye = {}
    local numc = -1
    for i = 0, N - 1 do
        numc = numc + 1
        local x1 = i / N * 0.2
        xc[numc] = -w * (0.3 * i / N - 1)
        yc[numc] = r1 * 0.48 * (math.sqrt(1 - (x1 / 0.12 - 1) ^ 2))
    end
    for i = 0, 3 * N do
        local x1 = 0.7 * i / (3 * N) + 0.2
        numc = numc + 1
        xc[numc] = -w * (-0.7 + 1.7 * i / (3 * N))
        yc[numc] = r1 * (3 * (x1 - 0.2) * (x1 - 0.6) + C1)
    end
    for j = 1, wN do
        obj.setoption("drawtarget", "tempbuffer", 2 * w, 2 * r1)
        obj.setoption("blend", "alpha_add")
        for i = 0, numc do
            local d = 0
            local e = 0
            for k = 1, 3 do
                d = d
                    + math.sin(
                            obj.rand(10, 20, k, j + 100 + seed) * 0.1 * math.pi * i / numc
                                + obj.rand(0, 731, k, j + 200 + seed) * 0.01
                        )
                        * obj.rand(30, 50, k, j + 300 + seed)
            end
            e = -d
            for k = 1, 3 do
                d = d
                    + math.sin(
                            obj.rand(100, 150, k, j + 400 + seed) * 0.1 * math.pi * i / numc
                                + obj.rand(0, 731, k, j + 500 + seed) * 0.01
                        )
                        * 15
                        / k
                e = e
                    + math.cos(
                            obj.rand(100, 150, k, j + 700 + seed) * 0.1 * math.pi * i / numc
                                + obj.rand(0, 731, k, j + 800 + seed) * 0.01
                        )
                        * 15
                        / k
            end
            yd[i] = yc[i] + d * 0.04
            ye[i] = yc[i] + e * 0.03
        end
        for i = 0, numc - 1 do
            obj.drawpoly(xc[i], -yd[i], 0, xc[i + 1], -yd[i + 1], 0, xc[i + 1], ye[i + 1], 0, xc[i], ye[i], 0)
        end
        obj.copybuffer("cache:HS1_img" .. j, "tmp")
    end

    --飛散2

    N = 20
    for j = 1, tN do
        local siz = Lh * 0.15 * obj.rand(95, 100, j, 9000 + seed) * 0.01
        local rh = obj.rand(200, 800, j, 10000 + seed)
        obj.setoption("drawtarget", "tempbuffer", 2 * siz, 2 * siz)
        obj.setoption("blend", "alpha_add")
        local r = {}
        local t = {}
        for i = 0, N - 1 do
            local d = 0
            for k = 1, 3 do
                d = d
                    + math.sin(2 * k * math.pi * i / N + obj.rand(0, 731, k, j + 200 + seed) * 0.01)
                        * obj.rand(20, 80, k, j + 300 + seed)
            end
            r[i] = siz * (1 + d * 0.001) * 0.5
            t[i] = i * 2 * math.pi / N
        end
        r[N] = r[0]
        t[N] = 0
        local x0, y0 = r[0], 0
        for i = 0, N - 1 do
            local x1, y1 = r[i + 1] * math.cos(t[i + 1]), r[i] * math.sin(t[i + 1])
            obj.drawpoly(x0, y0, 0, x0, y0, 0, x1, y1, 0, 0, 0, 0)
            x0, y0 = x1, y1
        end
        obj.copybuffer("cache:HS2_img" .. j, "tmp")
    end

    --本体

    obj.setoption("drawtarget", "tempbuffer", L, L)
    obj.setoption("blend", "alpha_add")
    local RR = {}
    for i = 0, 199 do
        local ff = 0
        for k = 1, 30 do
            local Cpp = 0.2 * (1 - Cp / (1 + (k - 1) * 0.01))
            ff = ff + math.sin((math.pi * k * i + obj.rand(0, 731, k, seed)) * 0.01) / k * Cpp
        end
        for k = 65, 80 do
            local Cpp = 0.15 * (1 - Cp / (1 + (k - 1) * 0.01))
            ff = ff + math.sin((math.pi * k * i + obj.rand(0, 731, k, seed)) * 0.01) / k * Cpp
        end
        RR[i] = (ff + 0.5) * Lh
    end
    RR[200] = RR[0]
    local r0
    local t0
    local x0, y0 = RR[0], 0
    for i = 0, 199 do
        local r1 = RR[i + 1]
        local t1 = (i + 1) * math.pi / 100
        local x1, y1 = r1 * math.cos(t1), r1 * math.sin(t1)
        obj.drawpoly(x0, y0, 0, x1, y1, 0, 0, 0, 0, 0, 0, 0)
        x0, y0 = x1, y1
    end

    --飛散1
    for i = 1, wN do
        obj.copybuffer("obj", "cache:HS1_img" .. i)
        local j = (obj.rand(0, 199 / wN, i, 1000 + seed) + math.floor(200 * i / wN)) % 200
        local rot = j * math.pi / 100
        local r0 = RR[j]
        local p1 = (Lh - r0) / (2 * w - r1) * obj.rand(50, 100, i, 2000 + seed) * 0.01
        local p2 = obj.rand(80, 100, i, 3000 + seed) * 0.01
        local p3 = obj.rand(50, 90, i, 4000 + seed) * 0.01
        local x1 = p3 * r0 - p1 * r1
        local x2 = p3 * r0 + p1 * (2 * w - r1)
        local y2 = r1 * p1 * p2
        local y1 = -y2
        local cos = math.cos(rot)
        local sin = math.sin(rot)
        local u0, v0 = x1 * cos - y1 * sin, x1 * sin + y1 * cos
        local u1, v1 = x2 * cos - y1 * sin, x2 * sin + y1 * cos
        local u2, v2 = x2 * cos - y2 * sin, x2 * sin + y2 * cos
        local u3, v3 = x1 * cos - y2 * sin, x1 * sin + y2 * cos
        obj.drawpoly(u0, v0, 0, u1, v1, 0, u2, v2, 0, u3, v3, 0)
    end

    --飛散2
    for i = 1, tN do
        obj.copybuffer("obj", "cache:HS2_img" .. i)
        local de = obj.rand(0, 360, i, 11000 + seed)
        local B = obj.rand(66, 100, i, 6000 + seed) * 0.01
        local r0 = obj.rand(Lh * 0.5, Lh * 0.85, i, 7000 + seed)
        local j = (obj.rand(0, 199 / tN, i, 8000 + seed) + math.floor(200 * i / tN)) % 200
        local rot = j * math.pi / 100
        local ox, oy = r0 * math.cos(rot), r0 * math.sin(rot)
        obj.draw(ox, oy, 0, B, 1, 0, 0, de)
    end
    obj.load("tempbuffer")
end
