--label:tim2\アニメーション効果
---$track:ひねり量
---min=0
---max=100
---step=0.01
local track_twist_amount = 50

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$track:中心ズレ
---min=-5000
---max=5000
---step=0.1
local track_center_offset = 0

---$track:切替映像
---min=-1
---max=1000
---step=1
local track_switch_video = 0

---$check:レイヤー読込
local check0 = true

---$track:分割数
---min=5
---max=300
---step=1
local track_division_count = 25

---$track:収束半径
---min=0
---max=5000
---step=0.01
local track_convergence_radius = 0.1

---$track:シェーディング[%]
---min=0
---max=100
---step=0.1
local track_shading_strength = 100

---$check:シェーディングを逆に
local check_reverse_shading = 0

---$track:範囲拡張X
---min=-5000
---max=5000
---step=1
local track_expand_x = 0

---$track:範囲拡張Y
---min=-5000
---max=5000
---step=1
local track_expand_y = 0

local Twister = function(
    posx,
    posy,
    Tw,
    Rt,
    Cw,
    N,
    w,
    h,
    w2,
    h2,
    sin,
    cos,
    wd,
    hd,
    cx,
    cy,
    dr,
    num,
    muki,
    x1,
    y1,
    x2,
    y2,
    x3,
    y3,
    x4,
    y4,
    x5,
    y5
)
    obj.copybuffer("obj", "cache:img" .. num)

    if x5 == nil then
        x4 = x4 or x3
        y4 = y4 or y3
        for i = 0, N do
            local xa = (i * x4 + (N - i) * x1) / N
            local ya = (i * y4 + (N - i) * y1) / N
            local xb = (i * x3 + (N - i) * x2) / N
            local yb = (i * y3 + (N - i) * y2) / N
            for j = 0, N do
                posx[i][j] = (j * xb + (N - j) * xa) / N
                posy[i][j] = (j * yb + (N - j) * ya) / N
            end
        end
    else
        if muki == 0 then
            x1, x2, x3, x4, x5 = x2, x1, x5, x4, x3
            y1, y2, y3, y4, y5 = y2, y1, y5, y4, y3
        end
        local K1 = math.sqrt((x2 - x3) * (x2 - x3) + (y2 - y3) * (y2 - y3))
        local K2 = math.sqrt((x4 - x5) * (x4 - x5) + (y4 - y5) * (y4 - y5))
        local N2 = math.min(math.max(1, math.floor(N * K1 / K2)), N - 1)
        local N1 = N - N2
        for i = 0, N do
            local xa
            local ya
            if i <= N1 then
                xa = (i * x2 + (N1 - i) * x1) / N1
                ya = (i * y2 + (N1 - i) * y1) / N1
            else
                xa = ((i - N1) * x3 + (N - i) * x2) / N2
                ya = ((i - N1) * y3 + (N - i) * y2) / N2
            end
            local xb = (i * x4 + (N - i) * x5) / N
            local yb = (i * y4 + (N - i) * y5) / N
            for j = 0, N do
                posx[i][j] = (j * xb + (N - j) * xa) / N
                posy[i][j] = (j * yb + (N - j) * ya) / N
            end
        end
    end

    dr = dr * dr
    local wd2, hd2 = wd * 0.5, hd * 0.5
    local posu = {}
    local posv = {}
    local scx = cos * Cw
    local scy = -sin * Cw
    for i = 0, N do
        posu[i] = {}
        posv[i] = {}
        for j = 0, N do
            posu[i][j] = posx[i][j] + w2
            posv[i][j] = posy[i][j] + h2

            local t = sin * posx[i][j] + cos * posy[i][j] - 2 * hd * Tw
            if -hd2 <= t and t <= hd2 then
                t = math.abs(math.sin(t * math.pi / hd))
                local x = posx[i][j] + cos * (-cos * (posx[i][j] + scx) + sin * (posy[i][j] + scy)) * (1 - t)
                local y = posy[i][j] - sin * (-cos * (posx[i][j] + scx) + sin * (posy[i][j] + scy)) * (1 - t)
                if (x - cx + scx) * (x - cx + scx) + (y - cy + scy) * (y - cy + scy) < dr then
                    posx[i][j], posy[i][j] = cx - scx, cy - scy
                else
                    posx[i][j], posy[i][j] = x, y
                end
            end
        end
    end
    for i = 0, N - 1 do
        local ihan = (i == 0) or (i == N - 1)
        for j = 0, N - 1 do
            if j == 0 or j == N - 1 or ihan then
                obj.setoption("antialias", 1)
            else
                obj.setoption("antialias", 0)
            end
            obj.drawpoly(
                posx[i][j],
                posy[i][j],
                0,
                posx[i + 1][j],
                posy[i + 1][j],
                0,
                posx[i + 1][j + 1],
                posy[i + 1][j + 1],
                0,
                posx[i][j + 1],
                posy[i][j + 1],
                0,
                posu[i][j],
                posv[i][j],
                posu[i + 1][j],
                posv[i + 1][j],
                posu[i + 1][j + 1],
                posv[i + 1][j + 1],
                posu[i][j + 1],
                posv[i][j + 1]
            )
        end
    end
end

local MakeShading = function(cx, cy, wd, hd, sin, cos, Cw, sdg, srev)
    local cl
    if srev == 0 then
        cl = 0xffffff
    else
        cl = 0x000000
    end

    obj.load("figure", "円", cl, hd / 3)
    obj.effect("ぼかし", "範囲", hd / 8)

    local wd2 = wd * 0.5
    local hd8 = hd / 8

    local x = cx - hd8 * sin - wd2 * cos
    local y = cy - hd8 * cos + wd2 * sin
    local dx1 = wd2 * cos
    local dy1 = -wd2 * sin
    local dx2 = hd / 4 * sin
    local dy2 = hd / 4 * cos
    obj.drawpoly(
        x - dx1 - dx2,
        y - dy1 - dy2,
        0,
        x + dx1 - dx2 - cos * Cw,
        y + dy1 - dy2 + sin * Cw,
        0,
        x + dx1 + dx2 - cos * Cw,
        y + dy1 + dy2 + sin * Cw,
        0,
        x - dx1 + dx2,
        y - dy1 + dy2,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        sdg
    )

    obj.effect("反転", "輝度反転", 1)
    x = cx + hd8 * sin + wd2 * cos
    y = cy + hd8 * cos - wd2 * sin
    obj.drawpoly(
        x - dx1 - dx2 - cos * Cw,
        y - dy1 - dy2 + sin * Cw,
        0,
        x + dx1 - dx2,
        y + dy1 - dy2,
        0,
        x + dx1 + dx2,
        y + dy1 + dy2,
        0,
        x - dx1 + dx2 - cos * Cw,
        y - dy1 + dy2 + sin * Cw,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        sdg
    )
end

local Tw = track_twist_amount * 0.01 - 0.5
local Do = track_rotation
local Rt = math.rad(180 - Do)
local Cw = track_center_offset
local id = math.floor(track_switch_video)

local division_count = math.floor(math.max(track_division_count or 25, 5))
local convergence_radius = math.abs(track_convergence_radius or 0.1)
local shading_strength = math.abs(track_shading_strength or 100) * 0.01
local expand_x = track_expand_x or 0
local expand_y = track_expand_y or 0

local w, h = obj.getpixel()
local w2, h2 = w * 0.5, h * 0.5

local sin = math.sin(Rt)
local cos = math.cos(Rt)

local hd = w * math.abs(sin) + h * math.abs(cos)
local wd = w * math.abs(cos) + h * math.abs(sin)

local cx = Tw * hd * sin * 2
local cy = Tw * hd * cos * 2

if shading_strength > 0 then
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.draw()
    MakeShading(cx, cy, wd, hd, sin, cos, Cw, shading_strength, check_reverse_shading)
    obj.copybuffer("cache:img0", "tmp")
else
    obj.copybuffer("cache:img0", "obj")
end

if id > 0 then
    if check0 == false then
        ---$embed
        local extbuffer = require("extbuffer")
        extbuffer.read(id)
    else
        obj.load("layer", id, true)
    end

    if shading_strength > 0 then
        obj.setoption("drawtarget", "tempbuffer", w, h)
        obj.draw()
        MakeShading(cx, cy, wd, hd, sin, cos, Cw, shading_strength, check_reverse_shading)
        obj.copybuffer("cache:img1", "tmp")
    else
        obj.copybuffer("cache:img1", "obj")
    end
elseif id < 0 then
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.copybuffer("cache:img1", "tmp")
else
    obj.copybuffer("obj", "cache:img0")
    obj.copybuffer("cache:img1", "obj")
end

obj.setoption("drawtarget", "tempbuffer", math.max(w + expand_x, 1), math.max(h + expand_y, 1))
obj.setoption("blend", "alpha_add")

local posx = {}
local posy = {}
for i = 0, division_count do
    posx[i] = {}
    posy[i] = {}
end

local muki = 0
if math.abs(cos) < math.abs(sin) then -- if math.abs(cos*h)<math.abs(sin*w) then
    muki = 1
end

local z = {}
local kasan = 0

if (Do - 90) % 180 == 0 then
    if -w2 < cx and cx < w2 then
        kasan = 5
        z[0] = cx
        z[2] = cx
    end
elseif Do % 180 == 0 then
    if -h2 < cy and cy < h2 then
        kasan = 10
        z[1] = cy
        z[3] = cy
    end
else
    local A1 = cos * h2 / sin
    local B1 = cos * cy / sin + cx
    local A2 = sin * w2 / cos
    local B2 = sin * cx / cos + cy

    z[0] = A1 + B1
    z[1] = -A2 + B2
    z[2] = -A1 + B1
    z[3] = A2 + B2

    if -w2 <= z[0] and z[0] < w2 then
        kasan = kasan + 1
    end
    if -h2 <= z[1] and z[1] < h2 then
        kasan = kasan + 2
    end
    if -w2 < z[2] and z[2] <= w2 then
        kasan = kasan + 4
    end
    if -h2 < z[3] and z[3] <= h2 then
        kasan = kasan + 8
    end
end

local num = 1

if kasan == 3 then
    if sin > 0 then
        num = 1
    else
        num = 0
    end
    Twister(
        posx,
        posy,
        Tw,
        Rt,
        Cw,
        division_count,
        w,
        h,
        w2,
        h2,
        sin,
        cos,
        wd,
        hd,
        cx,
        cy,
        convergence_radius,
        num,
        muki,
        z[0],
        -h2,
        w2,
        z[1],
        w2,
        h2,
        -w2,
        h2,
        -w2,
        -h2
    )
    Twister(
        posx,
        posy,
        Tw,
        Rt,
        Cw,
        division_count,
        w,
        h,
        w2,
        h2,
        sin,
        cos,
        wd,
        hd,
        cx,
        cy,
        convergence_radius,
        1 - num,
        muki,
        w2,
        z[1],
        z[0],
        -h2,
        w2,
        -h2
    )
elseif kasan == 6 then
    if sin > 0 then
        num = 1
    else
        num = 0
    end
    Twister(
        posx,
        posy,
        Tw,
        Rt,
        Cw,
        division_count,
        w,
        h,
        w2,
        h2,
        sin,
        cos,
        wd,
        hd,
        cx,
        cy,
        convergence_radius,
        num,
        muki,
        w2,
        z[1],
        z[2],
        h2,
        -w2,
        h2,
        -w2,
        -h2,
        w2,
        -h2
    )
    Twister(
        posx,
        posy,
        Tw,
        Rt,
        Cw,
        division_count,
        w,
        h,
        w2,
        h2,
        sin,
        cos,
        wd,
        hd,
        cx,
        cy,
        convergence_radius,
        1 - num,
        muki,
        z[2],
        h2,
        w2,
        z[1],
        w2,
        h2
    )
elseif kasan == 12 then
    if sin < 0 then
        num = 1
    else
        num = 0
    end
    Twister(
        posx,
        posy,
        Tw,
        Rt,
        Cw,
        division_count,
        w,
        h,
        w2,
        h2,
        sin,
        cos,
        wd,
        hd,
        cx,
        cy,
        convergence_radius,
        num,
        muki,
        z[2],
        h2,
        -w2,
        z[3],
        -w2,
        -h2,
        w2,
        -h2,
        w2,
        h2
    )
    Twister(
        posx,
        posy,
        Tw,
        Rt,
        Cw,
        division_count,
        w,
        h,
        w2,
        h2,
        sin,
        cos,
        wd,
        hd,
        cx,
        cy,
        convergence_radius,
        1 - num,
        muki,
        -w2,
        z[3],
        z[2],
        h2,
        -w2,
        h2
    )
elseif kasan == 9 then
    if sin < 0 then
        num = 1
    else
        num = 0
    end
    Twister(
        posx,
        posy,
        Tw,
        Rt,
        Cw,
        division_count,
        w,
        h,
        w2,
        h2,
        sin,
        cos,
        wd,
        hd,
        cx,
        cy,
        convergence_radius,
        num,
        muki,
        -w2,
        z[3],
        z[0],
        -h2,
        w2,
        -h2,
        w2,
        h2,
        -w2,
        h2
    )
    Twister(
        posx,
        posy,
        Tw,
        Rt,
        Cw,
        division_count,
        w,
        h,
        w2,
        h2,
        sin,
        cos,
        wd,
        hd,
        cx,
        cy,
        convergence_radius,
        1 - num,
        muki,
        z[0],
        -h2,
        -w2,
        z[3],
        -w2,
        -h2
    )
elseif kasan == 5 then
    if sin > 0 then
        num = 1
    else
        num = 0
    end
    Twister(
        posx,
        posy,
        Tw,
        Rt,
        Cw,
        division_count,
        w,
        h,
        w2,
        h2,
        sin,
        cos,
        wd,
        hd,
        cx,
        cy,
        convergence_radius,
        num,
        muki,
        -w2,
        -h2,
        z[0],
        -h2,
        z[2],
        h2,
        -w2,
        h2
    )
    Twister(
        posx,
        posy,
        Tw,
        Rt,
        Cw,
        division_count,
        w,
        h,
        w2,
        h2,
        sin,
        cos,
        wd,
        hd,
        cx,
        cy,
        convergence_radius,
        1 - num,
        muki,
        w2,
        -h2,
        w2,
        h2,
        z[2],
        h2,
        z[0],
        -h2
    )
elseif kasan == 10 then
    if cos > 0 then
        num = 1
    else
        num = 0
    end
    Twister(
        posx,
        posy,
        Tw,
        Rt,
        Cw,
        division_count,
        w,
        h,
        w2,
        h2,
        sin,
        cos,
        wd,
        hd,
        cx,
        cy,
        convergence_radius,
        num,
        muki,
        -w2,
        -h2,
        w2,
        -h2,
        w2,
        z[1],
        -w2,
        z[3]
    )
    Twister(
        posx,
        posy,
        Tw,
        Rt,
        Cw,
        division_count,
        w,
        h,
        w2,
        h2,
        sin,
        cos,
        wd,
        hd,
        cx,
        cy,
        convergence_radius,
        1 - num,
        muki,
        w2,
        h2,
        -w2,
        h2,
        -w2,
        z[3],
        w2,
        z[1]
    )
else
    if Tw > 0 then
        num = 1
    else
        num = 0
    end
    Twister(
        posx,
        posy,
        Tw,
        Rt,
        Cw,
        division_count,
        w,
        h,
        w2,
        h2,
        sin,
        cos,
        wd,
        hd,
        cx,
        cy,
        convergence_radius,
        num,
        muki,
        -w2,
        -h2,
        w2,
        -h2,
        w2,
        h2,
        -w2,
        h2
    )
end

obj.load("tempbuffer")
