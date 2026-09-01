--label:${ROOT_CATEGORY}\カスタムオブジェクト
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
local color = 0xffffff

---$check:新描画法
local check_use_new_rendering = true

---$track:本体拡大率%
---min=0
---max=300
---step=0.1
local track_body_scale_percent = 100

---$track:飛沫数1
---min=0
---max=100
---step=1
local track_splash_count_1 = 5

---$track:飛沫数2
---min=0
---max=100
---step=1
local track_splash_count_2 = 4

---$track:飛散1幅拡大率%
---min=0
---max=300
---step=0.1
local track_splash_1_width_scale_percent = 100

---$track:飛散2拡大率%
---min=0
---max=300
---step=0.1
local track_splash_2_scale_percent = 100

---$track:飛散2歪み%
---min=0
---max=100
---step=0.1
local track_splash_2_distortion_percent = 0

---$track:本体変化乱数
---min=0
---max=100000
---step=1
local track_body_shape_seed = 0

---$track:飛散変化乱数1
---min=0
---max=100000
---step=1
local track_splash_seed_1 = 0

---$track:飛散変化乱数2
---min=0
---max=100000
---step=1
local track_splash_seed_2 = 0

--hide@track_body_scale_percent:check_use_new_rendering==0
--hide@track_splash_1_width_scale_percent:check_use_new_rendering==0
--hide@track_splash_2_scale_percent:check_use_new_rendering==0
--hide@track_splash_2_distortion_percent:check_use_new_rendering==0
--hide@track_body_shape_seed:check_use_new_rendering==0
--hide@track_splash_seed_1:check_use_new_rendering==0
--hide@track_splash_seed_2:check_use_new_rendering==0

local use_new_rendering = check_use_new_rendering == true or check_use_new_rendering == 1
local splash_count_1 = math.floor(math.abs(track_splash_count_1 or 0))
local splash_count_2 = math.floor(math.abs(track_splash_count_2 or 0))
local body_seed = math.floor(math.abs(track_body_shape_seed or 0))
local splash_seed_1 = math.floor(math.abs(track_splash_seed_1 or 0))
local splash_seed_2 = math.floor(math.abs(track_splash_seed_2 or 0))
local body_scale = (track_body_scale_percent or 100) * 0.01
local splash_width_scale = (track_splash_1_width_scale_percent or 100) * 0.01
local splash_scale_2 = (track_splash_2_scale_percent or 100) * 0.01
local splash_distortion_2 = (track_splash_2_distortion_percent or 0) * 0.02

if use_new_rendering then
    local l = track_size
    local cp = track_roundness * 0.01
    local lh = l * 0.5
    local seed = track_shape
    local dev = track_unfold * 0.01
    obj.load("figure", "四角形", color, 1)
    local threshold_1 = {}
    local threshold_2 = {}
    for j = 1, splash_count_1 do
        threshold_1[j] = obj.rand(30, 60, -j - splash_seed_1, 10000 + seed) * 0.01
    end
    for j = 1, splash_count_2 do
        threshold_2[j] = obj.rand(20, 80, -j - splash_seed_2, 11000 + seed) * 0.01
    end
    --飛散1
    local r1 = 30 * 0.5
    local w = 100 * 0.5

    local c1 = 4 * math.sqrt(0.12 * 0.12 - (0.2 - 0.12) ^ 2)
    local xc = {}
    local yc = {}
    local yd = {}
    local ye = {}
    local numc = -1

    if dev > 0.3 then
        local r1 = r1 * splash_width_scale
        local n1 = 18
        local n2 = 102
        for i = 0, n1 - 1 do
            numc = numc + 1
            local x1 = i / n1 * 0.2
            xc[numc] = -w * (0.3 * i / n1 - 1)
            yc[numc] = r1 * 0.48 * (math.sqrt(1 - (x1 / 0.12 - 1) ^ 2))
        end
        for i = 0, n2 do
            local x1 = 0.7 * i / n2 + 0.2
            numc = numc + 1
            xc[numc] = -w * (-0.7 + 1.7 * i / n2)
            yc[numc] = r1 * (3 * (x1 - 0.2) * (x1 - 0.6) + c1)
        end
    end
    for j = 1, splash_count_1 do
        if dev > threshold_1[j] then
            local dd = 3 * (dev - threshold_1[j])
            dd = dd > 1 and 1 or dd
            dd = dd * (2 - dd)
            local d_n = math.floor(numc * (1 - dd))

            local ycc = {}
            for i = 0, d_n - 1 do
                ycc[i] = 0
            end
            for i = d_n, numc do
                ycc[i] = yc[i - d_n]
            end
            obj.setoption("drawtarget", "tempbuffer", 2 * w, 2 * r1)
            obj.setoption("blend", "alpha_add")
            for i = 0, numc do
                local d = 0
                local e = 0
                if ycc[i] > 0 then
                    for k = 1, 3 do
                        local kk = k + splash_seed_1
                        d = d
                            + math.sin(
                                    obj.rand(10, 20, -kk, j + 100 + seed) * 0.1 * math.pi * i / numc
                                        + obj.rand(0, 731, -kk, j + 200 + seed) * 0.01
                                )
                                * obj.rand(30, 50, -kk, j + 300 + seed)
                    end
                    e = -d
                    for k = 1, 3 do
                        local kk = k + splash_seed_1
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
            obj.copybuffer("cache:HS1_img" .. j, "tempbuffer")
        end
    end

    --本体
    local dd = dev * 1.5
    dd = dd > 1 and 1 or dd
    dd = dd * (2 - dd)
    obj.setoption("drawtarget", "tempbuffer", l, l)
    obj.setoption("blend", "alpha_add")
    local rr = {}
    for i = 0, 199 do
        local ff = 0
        for k = 1, 30 do
            local cpp = 0.2 * (1 - cp / (1 + (k - 1) * 0.01))
            ff = ff + math.sin((math.pi * k * i + obj.rand(0, 731, -k - body_seed, seed)) * 0.01) / k * cpp
        end
        for k = 65, 80 do
            local cpp = 0.15 * (1 - cp / (1 + (k - 1) * 0.01))
            ff = ff + math.sin((math.pi * k * i + obj.rand(0, 731, -k - body_seed, seed)) * 0.01) / k * cpp
        end
        rr[i] = (ff * dd + 0.5) * lh * dd * body_scale
    end
    rr[200] = rr[0]
    for i = 1, 4 do
        rr[-i] = rr[200 - i]
        rr[200 + i] = rr[i]
    end
    local r0
    local t0
    local x0, y0 = rr[0], 0
    for i = 1, 200 do
        local r1 = rr[i]
        local t1 = i * math.pi / 100
        local x1, y1 = r1 * math.cos(t1), r1 * math.sin(t1)
        obj.drawpoly(x0, y0, 0, x1, y1, 0, 0, 0, 0, 0, 0, 0)
        x0, y0 = x1, y1
    end

    --飛散1
    for i = 1, splash_count_1 do
        if dev > threshold_1[i] then
            local ii = i + splash_seed_1
            obj.copybuffer("object", "cache:HS1_img" .. i)
            local j = (obj.rand(0, 199 / splash_count_1, -ii, 1000 + seed) + math.floor(200 * i / splash_count_1)) % 200
            local angle_radians = j * math.pi / 100
            local p2 = obj.rand(80, 100, -ii, 3000 + seed) * 0.01
            local p3 = obj.rand(70, 90, -ii, 4000 + seed) * 0.01
            local hsl = lh * obj.rand(25, 80, -ii, 2000 + seed) * 0.01
            local x1 = p3
                * math.min(
                    rr[j - 4],
                    rr[j - 3],
                    rr[j - 2],
                    rr[j - 1],
                    rr[j],
                    rr[j + 1],
                    rr[j + 2],
                    rr[j + 3],
                    rr[j + 4],
                    lh - hsl
                )
            local x2 = x1 + p3 * hsl
            local y2 = p2 * hsl * r1 / w * 0.5

            local y1 = -y2
            local cos = math.cos(angle_radians)
            local sin = math.sin(angle_radians)
            local u0, v0 = x1 * cos - y1 * sin, x1 * sin + y1 * cos
            local u1, v1 = x2 * cos - y1 * sin, x2 * sin + y1 * cos
            local u2, v2 = x2 * cos - y2 * sin, x2 * sin + y2 * cos
            local u3, v3 = x1 * cos - y2 * sin, x1 * sin + y2 * cos
            obj.drawpoly(u0, v0, 0, u1, v1, 0, u2, v2, 0, u3, v3, 0)
            obj.load("figure", "四角形", color, 1)
            obj.drawpoly(u0, v0, 0, 0, 0, 0, 0, 0, 0, u3, v3, 0)
        end
    end

    --飛散2

    obj.load("figure", "四角形", color, 1)

    for j = 1, splash_count_2 do
        if dev > threshold_2[j] then
            local dd = 10 * (dev - threshold_2[j])
            dd = dd > 1 and 1 or dd
            dd = dd * (2 - dd) * splash_scale_2
            local n = 20
            local jj = j + splash_seed_2
            local k = (obj.rand(0, 199 / splash_count_2, -jj, 8000 + seed) + math.floor(200 * j / splash_count_2)) % 200
            local angle_radians = k * math.pi / 100
            local r0 = lh * obj.rand(50, 85, -jj, 7000 + seed) * 0.01
            local ox, oy = r0 * math.cos(angle_radians), r0 * math.sin(angle_radians)
            local de = obj.rand(0, 628, -jj, 11000 + seed) * 0.01
            local siz = lh * 0.15 * obj.rand(40, 90, -jj, 9000 + seed) * 0.01 * 0.5 * dd
            local rh = obj.rand(200, 800, -jj, 10000 + seed)
            local r = {}
            local t = {}
            for i = 0, n - 1 do
                local d = 0
                for k = 1, 3 do
                    d = d
                        + math.sin(
                                2 * k * math.pi * i / n
                                    + obj.rand(0, 731, -k - splash_seed_2, j + 200 + seed) * 0.01
                                    + de
                            )
                            * obj.rand(20, 80, -k - splash_seed_2, j + 300 + seed)
                end
                local x = 1 - math.abs(i - n / 2) / (n / 2)
                r[i] = siz * (1 + d * 0.001) * (splash_distortion_2 * x * x * (x - 1) + 1) ^ 1.5
                t[i] = i * 2 * math.pi / n + angle_radians
            end
            r[n] = r[0]
            t[n] = 0 + angle_radians
            local x0, y0 = r[0] * math.cos(t[0]) + ox, r[0] * math.sin(t[0]) + oy
            for i = 1, n do
                local x1, y1 = r[i] * math.cos(t[i]) + ox, r[i] * math.sin(t[i]) + oy
                obj.drawpoly(x0, y0, 0, x0, y0, 0, x1, y1, 0, ox, oy, 0)
                x0, y0 = x1, y1
            end
        end
    end

    obj.load("tempbuffer")
else --ここからOLD-------
    local l = track_size
    local cp = track_roundness * 0.01
    local lh = l * 0.5
    local seed = track_shape
    local n = 30
    obj.load("figure", "四角形", color, 1)
    --飛散1
    local r1 = 30 * 0.5
    local w = 100 * 0.5
    local c1 = 4 * math.sqrt(0.12 * 0.12 - (0.2 - 0.12) ^ 2)
    local xc = {}
    local yc = {}
    local yd = {}
    local ye = {}
    local numc = -1
    for i = 0, n - 1 do
        numc = numc + 1
        local x1 = i / n * 0.2
        xc[numc] = -w * (0.3 * i / n - 1)
        yc[numc] = r1 * 0.48 * (math.sqrt(1 - (x1 / 0.12 - 1) ^ 2))
    end
    for i = 0, 3 * n do
        local x1 = 0.7 * i / (3 * n) + 0.2
        numc = numc + 1
        xc[numc] = -w * (-0.7 + 1.7 * i / (3 * n))
        yc[numc] = r1 * (3 * (x1 - 0.2) * (x1 - 0.6) + c1)
    end
    for j = 1, splash_count_1 do
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
        obj.copybuffer("cache:HS1_img" .. j, "tempbuffer")
    end

    --飛散2

    n = 20
    for j = 1, splash_count_2 do
        local siz = lh * 0.15 * obj.rand(95, 100, j, 9000 + seed) * 0.01
        local rh = obj.rand(200, 800, j, 10000 + seed)
        obj.setoption("drawtarget", "tempbuffer", 2 * siz, 2 * siz)
        obj.setoption("blend", "alpha_add")
        local r = {}
        local t = {}
        for i = 0, n - 1 do
            local d = 0
            for k = 1, 3 do
                d = d
                    + math.sin(2 * k * math.pi * i / n + obj.rand(0, 731, k, j + 200 + seed) * 0.01)
                        * obj.rand(20, 80, k, j + 300 + seed)
            end
            r[i] = siz * (1 + d * 0.001) * 0.5
            t[i] = i * 2 * math.pi / n
        end
        r[n] = r[0]
        t[n] = 0
        local x0, y0 = r[0], 0
        for i = 0, n - 1 do
            local x1, y1 = r[i + 1] * math.cos(t[i + 1]), r[i] * math.sin(t[i + 1])
            obj.drawpoly(x0, y0, 0, x0, y0, 0, x1, y1, 0, 0, 0, 0)
            x0, y0 = x1, y1
        end
        obj.copybuffer("cache:HS2_img" .. j, "tempbuffer")
    end

    --本体

    obj.setoption("drawtarget", "tempbuffer", l, l)
    obj.setoption("blend", "alpha_add")
    local rr = {}
    for i = 0, 199 do
        local ff = 0
        for k = 1, 30 do
            local cpp = 0.2 * (1 - cp / (1 + (k - 1) * 0.01))
            ff = ff + math.sin((math.pi * k * i + obj.rand(0, 731, k, seed)) * 0.01) / k * cpp
        end
        for k = 65, 80 do
            local cpp = 0.15 * (1 - cp / (1 + (k - 1) * 0.01))
            ff = ff + math.sin((math.pi * k * i + obj.rand(0, 731, k, seed)) * 0.01) / k * cpp
        end
        rr[i] = (ff + 0.5) * lh
    end
    rr[200] = rr[0]
    local r0
    local t0
    local x0, y0 = rr[0], 0
    for i = 0, 199 do
        local r1 = rr[i + 1]
        local t1 = (i + 1) * math.pi / 100
        local x1, y1 = r1 * math.cos(t1), r1 * math.sin(t1)
        obj.drawpoly(x0, y0, 0, x1, y1, 0, 0, 0, 0, 0, 0, 0)
        x0, y0 = x1, y1
    end

    --飛散1
    for i = 1, splash_count_1 do
        obj.copybuffer("object", "cache:HS1_img" .. i)
        local j = (obj.rand(0, 199 / splash_count_1, i, 1000 + seed) + math.floor(200 * i / splash_count_1)) % 200
        local angle_radians = j * math.pi / 100
        local r0 = rr[j]
        local p1 = (lh - r0) / (2 * w - r1) * obj.rand(50, 100, i, 2000 + seed) * 0.01
        local p2 = obj.rand(80, 100, i, 3000 + seed) * 0.01
        local p3 = obj.rand(50, 90, i, 4000 + seed) * 0.01
        local x1 = p3 * r0 - p1 * r1
        local x2 = p3 * r0 + p1 * (2 * w - r1)
        local y2 = r1 * p1 * p2
        local y1 = -y2
        local cos = math.cos(angle_radians)
        local sin = math.sin(angle_radians)
        local u0, v0 = x1 * cos - y1 * sin, x1 * sin + y1 * cos
        local u1, v1 = x2 * cos - y1 * sin, x2 * sin + y1 * cos
        local u2, v2 = x2 * cos - y2 * sin, x2 * sin + y2 * cos
        local u3, v3 = x1 * cos - y2 * sin, x1 * sin + y2 * cos
        obj.drawpoly(u0, v0, 0, u1, v1, 0, u2, v2, 0, u3, v3, 0)
    end

    --飛散2
    for i = 1, splash_count_2 do
        obj.copybuffer("object", "cache:HS2_img" .. i)
        local de = obj.rand(0, 360, i, 11000 + seed)
        local b = obj.rand(66, 100, i, 6000 + seed) * 0.01
        local r0 = obj.rand(lh * 0.5, lh * 0.85, i, 7000 + seed)
        local j = (obj.rand(0, 199 / splash_count_2, i, 8000 + seed) + math.floor(200 * i / splash_count_2)) % 200
        local angle_radians = j * math.pi / 100
        local ox, oy = r0 * math.cos(angle_radians), r0 * math.sin(angle_radians)
        obj.draw(ox, oy, 0, b, 1, 0, 0, de)
    end
    obj.load("tempbuffer")
end
