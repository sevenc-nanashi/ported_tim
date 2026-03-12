--label:tim2\カスタムオブジェクト
---$track:軌道番号
---min=1
---max=100
---step=1
local track_index = 1

---$select:軌道指定
---全リンク=0
---リンク1=1
---リンク2=2
---リンク3=3
local orbit_mode = 0

---$track:グラフサイズ
---min=50
---max=1000
---step=1
local track_graph_size = 200

---$value:アンカー
local pos = { -50, 50, 50, -50 }

---$check:グラフ表示
local check_show_graph = true

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
local orbit_index = track_index
local graph_size = track_graph_size
local half_graph_size = graph_size * 0.5
obj.setanchor("pos", 2)
local P1x, P1y, P2x, P2y = pos[1], pos[2], pos[3], pos[4]
if P1x < -half_graph_size then
    P1x = -half_graph_size
elseif P1x > half_graph_size then
    P1x = half_graph_size
end
if P2x < -half_graph_size then
    P2x = -half_graph_size
elseif P2x > half_graph_size then
    P2x = half_graph_size
end
local q1x, q1y, q2x, q2y =
    (P1x + half_graph_size) / graph_size,
    (-P1y + half_graph_size) / graph_size,
    (P2x + half_graph_size) / graph_size,
    (-P2y + half_graph_size) / graph_size
OrbitNumber[orbit_index] = { q1x, q1y, q2x, q2y, orbit_mode }

if check_show_graph then
    obj.setoption("drawtarget", "tempbuffer", 1.5 * graph_size, 2 * graph_size)

    local section_count = obj.getoption("section_num")
    local time_marks = {}
    for i = 0, section_count - 1 do
        time_marks[i] = obj.getvalue("time", 0, i)
    end
    time_marks[section_count] = obj.getvalue("time", 0, -1)
    local object_time = obj.time

    local z = 1
    if obj.frame < obj.totalframe - 1 then
        local i = 1
        while time_marks[i] <= object_time do
            i = i + 1
        end
        i = i - 1
        z = (object_time - time_marks[i]) / (time_marks[i + 1] - time_marks[i])
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
    x = x * graph_size - half_graph_size
    y = -(y * graph_size - half_graph_size)
    obj.draw(x, y)

    obj.load("figure", "四角形", 0x0, graph_size)
    obj.draw(0, 0, 0, 1, 0.5)
    obj.load("figure", "四角形", 0xffffff, graph_size, 5)
    obj.draw()
    obj.load("figure", "円", 0x00ff00, 5)

    for t = 0, 1, 0.01 do
        local x, y = Orbit(t, q1x, q1y, q2x, q2y, Cor)
        x = x * graph_size - half_graph_size
        y = -(y * graph_size - half_graph_size)
        obj.draw(x, y)
    end
    obj.load("figure", "円", 0xff0000, 20)
    obj.draw(P1x, P1y)
    obj.draw(P2x, P2y)
    obj.load("tempbuffer")
end