--label:tim2
---$track:軌道番号
---min=1
---max=100
---step=1
local track_index = 1

---$track:軌道指定
---min=0
---max=3
---step=1
local track_orbit_mode = 0

---$track:ｸﾞﾗﾌｻｲｽﾞ
---min=50
---max=1000
---step=1
local track_size = 200

---$value:アンカー
local pos = { -50, 50, 50, -50 }

---$check:グラフ表示
local check0 = true

local Orbit = function(t, x1, y1, x2, y2)
    local s = 1 - t
    x1 = (3 * s * s * x1 + (3 * s * x2 + t) * t) * t
    y1 = (3 * s * s * y1 + (3 * s * y2 + t) * t) * t
    return x1, y1
end

if OrbitNumber == nil then
    OrbitNumber = {}
end
pos = pos or { -50, 50, 50, -50 }
local n = track_index
local S = track_size
local Sh = S * 0.5
obj.setanchor("pos", 2)
local P1x, P1y, P2x, P2y = pos[1], pos[2], pos[3], pos[4]
if P1x < -Sh then
    P1x = -Sh
elseif P1x > Sh then
    P1x = Sh
end
if P2x < -Sh then
    P2x = -Sh
elseif P2x > Sh then
    P2x = Sh
end
local q1x, q1y, q2x, q2y = (P1x + Sh) / S, (-P1y + Sh) / S, (P2x + Sh) / S, (-P2y + Sh) / S
OrbitNumber[n] = { q1x, q1y, q2x, q2y, track_orbit_mode }

if check0 then
    obj.setoption("drawtarget", "tempbuffer", 1.5 * S, 2 * S)

    local N = obj.getoption("section_num")
    TM = {}
    for i = 0, N - 1 do
        TM[i] = obj.getvalue("time", 0, i)
    end
    TM[N] = obj.getvalue("time", 0, -1)
    local ot = obj.time

    local z = 1
    if ot < obj.totaltime then
        local i = 1
        while TM[i] <= ot do
            i = i + 1
        end
        i = i - 1
        z = (ot - TM[i]) / (TM[i + 1] - TM[i])
    end

    local t1 = 0
    local t2 = 1

    for i = 1, 10 do
        local tm = (t1 + t2) * 0.5
        local xm, y = Orbit(tm, q1x, q1y, q2x, q2y)
        if z < xm then
            t2 = tm
        else
            t1 = tm
        end
    end

    obj.load("figure", "円", 0xffff00, 20)
    local x, y = Orbit((t1 + t2) * 0.5, q1x, q1y, q2x, q2y)
    x = x * S - Sh
    y = -(y * S - Sh)
    obj.draw(x, y)

    obj.load("figure", "四角形", 0x0, S)
    obj.draw(0, 0, 0, 1, 0.5)
    obj.load("figure", "四角形", 0xffffff, S, 5)
    obj.draw()
    obj.load("figure", "円", 0x00ff00, 5)

    for t = 0, 1, 0.01 do
        local x, y = Orbit(t, q1x, q1y, q2x, q2y, Cor)
        x = x * S - Sh
        y = -(y * S - Sh)
        obj.draw(x, y)
    end
    obj.load("figure", "円", 0xff0000, 20)
    obj.draw(P1x, P1y)
    obj.draw(P2x, P2y)
    obj.load("tempbuffer")
end
