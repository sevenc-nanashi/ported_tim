--label:tim2\切り替え効果
---$track:展開
---min=0
---max=100
---step=0.1
local track_unfold = 25

---$track:サイズ
---min=5
---max=5000
---step=0.1
local track_size = 50

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 45

---$track:縦横比[%]
---min=1
---max=100
---step=0.1
local track_aspect_ratio_percent = 5

---$select:ワイプタイプ
---扉=0
---放射(十字)=1
---矩形(十字)=2
---十字線=3
---菱形(十字)=4
---放射=5
---矩形=6
---直線=7
---菱形=8
local select_wipe_type = 0

---$check:反転
local rev = 0

---$track:中心座標X
---min=-10000
---max=10000
---step=0.1
local track_center_position_x = 0

---$track:中心座標Y
---min=-10000
---max=10000
---step=0.1
local track_center_position_y = 0

--trackgroup@track_center_position_x,track_center_position_y:中心座標

local wipe_door = function(b, S, R, A, n, L, Lh, cos, sin, cx, cy)
    local T = (L + S / A) * b
    local P = T * A
    obj.setoption("drawtarget", "tempbuffer", math.max(math.min(T, L), 6), math.max(math.min(P, L), 6))
    obj.load("figure", "四角形", 0xffffff, math.max(T, P, 6))
    obj.drawpoly(-T / 2, 0, 0, 0, -P / 2, 0, T / 2, 0, 0, 0, P / 2, 0)
    obj.copybuffer("obj", "tmp")
    obj.copybuffer("tmp", "cache:ori")
    obj.setoption("blend", "alpha_sub")
    local deg = track_rotation + 90
    for i = -n, n do
        local x = i * S
        local y = x * sin
        x = x * cos
        obj.draw(x + cx, y + cy, 0, 1, 1, 0, 0, deg)
    end
    obj.load("figure", "四角形", 0xffffff, L)
    for i = -n, n do
        local ai = math.abs(i)
        local u = ai * S
        local v = P * (1 - 2 / T * u) * 0.5
        if v > 0 then
            local dy = i * S
            local dx = -dy * sin + cx
            dy = dy * cos + cy
            local ar1x = Lh * cos
            local ar1y = Lh * sin
            local ar2x = -v * sin
            local ar2y = v * cos
            local x0, y0 = dx - ar1x - ar2x, dy - ar1y - ar2y
            local x1, y1 = dx + ar1x - ar2x, dy + ar1y - ar2y
            local x2, y2 = dx + ar1x + ar2x, dy + ar1y + ar2y
            local x3, y3 = dx - ar1x + ar2x, dy - ar1y + ar2y
            obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
        end
    end
end

local wipe_radial = function(b, S, R, A, n, L, Lh, cos, sin, cx, cy, repN)
    obj.setoption("drawtarget", "tempbuffer", L, L * A)

    obj.load("figure", "四角形", 0xffffff, L / 30)
    obj.setoption("blend", "alpha_add")
    for i = -30, 29 do
        local x1 = Lh * i / 30
        local x2 = Lh * (i + 1) / 30
        local y1 = A * (2 / L * x1 * x1 - Lh)
        local y2 = A * (2 / L * x2 * x2 - Lh)
        obj.drawpoly(x1, y1, 0, x2, y2, 0, x2, -y2, 0, x1, -y1, 0)
    end

    obj.copybuffer("obj", "tmp")
    obj.copybuffer("tmp", "cache:ori")
    obj.setoption("blend", "alpha_sub")
    local DD = S * S + 4 * A * A * L * L
    local Rmax = b * math.sqrt((DD + S * math.sqrt(DD)) / (8 * A * A))
    for i = -n, n do
        local y0 = i * S
        local Rw = Rmax * Rmax - y0 * y0
        if Rw > 0 then
            Rw = math.sqrt(Rw)
            local zoom = 2 * Rw / L
            local x0 = -y0 * sin
            y0 = y0 * cos
            obj.draw(x0 + cx, y0 + cy, 0, zoom, 1, 0, 0, track_rotation)
            if repN == 2 then
                obj.draw(y0 + cx, -x0 + cy, 0, zoom, 1, 0, 0, track_rotation + 90)
            end
        end
    end
end

local wipe_rectangular = function(b, S, R, A, n, L, Lh, cos, sin, cx, cy, repN)
    local Rotdraw = function(x0, y0, x1, y1, x2, y2, x3, y3, cos, sin, cx, cy)
        x0, y0 = x0 * cos - y0 * sin + cx, x0 * sin + y0 * cos + cy
        x1, y1 = x1 * cos - y1 * sin + cx, x1 * sin + y1 * cos + cy
        x2, y2 = x2 * cos - y2 * sin + cx, x2 * sin + y2 * cos + cy
        x3, y3 = x3 * cos - y3 * sin + cx, x3 * sin + y3 * cos + cy
        obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
    end
    local T = (L + S / A) * b * 0.5
    local P = T * A
    obj.copybuffer("tmp", "cache:ori")
    obj.setoption("drawtarget", "tempbuffer")
    obj.load("figure", "四角形", 0xffffff, L * 0.5)
    obj.effect("リサイズ", "Y", track_aspect_ratio_percent)
    obj.setoption("blend", "alpha_sub")
    for i = -n, n do
        local y0 = i * S
        local yA = math.abs(y0)
        local P1 = P * (1 - yA / T)
        if P1 > 0 then
            Rotdraw(-T, y0, -T, y0, -yA, -P1 + y0, -yA, P1 + y0, cos, sin, cx, cy)
            Rotdraw(T, y0, T, y0, yA, P1 + y0, yA, -P1 + y0, cos, sin, cx, cy)
            Rotdraw(-yA, -P1 + y0, yA, -P1 + y0, yA, P1 + y0, -yA, P1 + y0, cos, sin, cx, cy)
            if repN == 2 then
                Rotdraw(-T, y0, -T, y0, -yA, -P1 + y0, -yA, P1 + y0, -sin, cos, cx, cy)
                Rotdraw(T, y0, T, y0, yA, P1 + y0, yA, -P1 + y0, -sin, cos, cx, cy)
                Rotdraw(-yA, -P1 + y0, yA, -P1 + y0, yA, P1 + y0, -yA, P1 + y0, -sin, cos, cx, cy)
            end
        end
    end
end

local wipe_crossline = function(b, S, R, A, n, L, Lh, cos, sin, cx, cy, repN)
    local T = (L + S / A) * b
    local P = T * A
    local width, height = obj.getpixel()
    obj.setoption("drawtarget", "tempbuffer", width, height)
    obj.copybuffer("tmp", "cache:ori")
    obj.setoption("blend", "alpha_sub")
    obj.load("figure", "四角形", 0xffffff, L)
    for j = 1, repN do
        for i = -n, n do
            local ai = math.abs(i)
            local u = ai * S
            local v = P * (1 - 2 / T * u) * 0.5
            if v > 0 then
                local dy = i * S
                local dx = -dy * sin + cx
                dy = dy * cos + cy
                local ar1x = Lh * cos
                local ar1y = Lh * sin
                local ar2x = -v * sin
                local ar2y = v * cos
                local x0, y0 = dx - ar1x - ar2x, dy - ar1y - ar2y
                local x1, y1 = dx + ar1x - ar2x, dy + ar1y - ar2y
                local x2, y2 = dx + ar1x + ar2x, dy + ar1y + ar2y
                local x3, y3 = dx - ar1x + ar2x, dy - ar1y + ar2y
                obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
            end
        end
        cos, sin = -sin, cos
    end
end

local wipe_diamond = function(b, S, R, A, n, L, Lh, cos, sin, cx, cy, repN)
    local T = (L + S / A) * b
    local P = T * A
    obj.setoption("drawtarget", "tempbuffer", math.max(math.min(T, L), 6), math.max(math.min(P, L), 6))
    obj.load("figure", "四角形", 0xffffff, math.max(T, P, 6))
    obj.drawpoly(-T / 2, 0, 0, 0, -P / 2, 0, T / 2, 0, 0, 0, P / 2, 0)
    obj.copybuffer("obj", "tmp")
    obj.copybuffer("tmp", "cache:ori")
    obj.setoption("blend", "alpha_sub")
    local deg = track_rotation
    for i = -n, n do
        local x = i * S
        local y = x * cos
        x = -x * sin
        obj.draw(x + cx, y + cy, 0, 1, 1, 0, 0, deg)
        if repN == 2 then
            obj.draw(-y + cx, x + cy, 0, 1, 1, 0, 0, deg + 90)
        end
    end
end

local b = track_unfold * 0.01
local S = track_size
local R = math.rad(track_rotation)
local A = track_aspect_ratio_percent * 0.01

local w, h = obj.getpixel()

obj.setanchor("track_center_position_x,track_center_position_y", 0)
w = w + 2 * math.abs(track_center_position_x)
h = h + 2 * math.abs(track_center_position_y)

local L0 = math.sqrt(w * w + h * h)

local n0 = 0.5 * L0 / S
local n = math.ceil(n0)
local Lh = n0 * S
local L = 2 * Lh
local cos = math.cos(R)
local sin = math.sin(R)

obj.copybuffer("cache:ori", "object")

if select_wipe_type == 0 then
    wipe_door(b, S, R, A, n, L, Lh, cos, sin, track_center_position_x, track_center_position_y)
elseif select_wipe_type == 1 then
    wipe_radial(b, S, R, A, n, L, Lh, cos, sin, track_center_position_x, track_center_position_y, 2)
elseif select_wipe_type == 2 then
    wipe_rectangular(b, S, R, A, n, L, Lh, cos, sin, track_center_position_x, track_center_position_y, 2)
elseif select_wipe_type == 3 then
    wipe_crossline(b, S, R, A, n, L, Lh, cos, sin, track_center_position_x, track_center_position_y, 2)
elseif select_wipe_type == 4 then
    wipe_diamond(b, S, R, A, n, L, Lh, cos, sin, track_center_position_x, track_center_position_y, 2)
elseif select_wipe_type == 5 then
    wipe_radial(b, S, R, A, n, L, Lh, cos, sin, track_center_position_x, track_center_position_y, 1)
elseif select_wipe_type == 6 then
    wipe_rectangular(b, S, R, A, n, L, Lh, cos, sin, track_center_position_x, track_center_position_y, 1)
elseif select_wipe_type == 7 then
    wipe_crossline(b, S, R, A, n, L, Lh, cos, sin, track_center_position_x, track_center_position_y, 1)
else
    wipe_diamond(b, S, R, A, n, L, Lh, cos, sin, track_center_position_x, track_center_position_y, 1)
end

obj.copybuffer("obj", "tmp")
obj.setoption("blend", 0)
if rev == 1 then
    obj.effect("反転", "透明度反転", 1)
end
