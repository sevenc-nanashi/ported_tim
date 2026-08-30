--label:${ROOT_CATEGORY}\カスタムオブジェクト
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
local select_orbit_target = 0

---$track:グラフサイズ
---min=50
---max=1000
---step=1
local track_graph_size = 200

---$value:アンカー
local value_control_points = { -50, 50, 50, -50 }

---$check:グラフ表示
local check_show_graph = true

local evaluate_bezier = function(t, x1, y1, x2, y2)
    local inverse_time = 1 - t
    x1 = (3 * inverse_time * inverse_time * x1 + (3 * inverse_time * x2 + t) * t) * t
    y1 = (3 * inverse_time * inverse_time * y1 + (3 * inverse_time * y2 + t) * t) * t
    return x1, y1
end

if T_BEZIER_ORBITS == nil then
    T_BEZIER_ORBITS = {}
end
value_control_points = value_control_points or { -50, 50, 50, -50 }
local orbit_index = track_index
local graph_size = track_graph_size
local half_graph_size = graph_size * 0.5
obj.setanchor("value_control_points", 2)
local control_1_x, control_1_y, control_2_x, control_2_y =
    value_control_points[1], value_control_points[2], value_control_points[3], value_control_points[4]
if control_1_x < -half_graph_size then
    control_1_x = -half_graph_size
elseif control_1_x > half_graph_size then
    control_1_x = half_graph_size
end
if control_2_x < -half_graph_size then
    control_2_x = -half_graph_size
elseif control_2_x > half_graph_size then
    control_2_x = half_graph_size
end
local normalized_control_1_x, normalized_control_1_y, normalized_control_2_x, normalized_control_2_y =
    (control_1_x + half_graph_size) / graph_size,
    (-control_1_y + half_graph_size) / graph_size,
    (control_2_x + half_graph_size) / graph_size,
    (-control_2_y + half_graph_size) / graph_size
T_BEZIER_ORBITS[orbit_index] = {
    normalized_control_1_x,
    normalized_control_1_y,
    normalized_control_2_x,
    normalized_control_2_y,
    select_orbit_target,
}

if check_show_graph then
    obj.setoption("drawtarget", "tempbuffer", 1.5 * graph_size, 2 * graph_size)

    local section_count = obj.getoption("section_num")
    local time_marks = {}
    for i = 0, section_count - 1 do
        time_marks[i] = obj.getvalue("time", 0, i)
    end
    time_marks[section_count] = obj.getvalue("time", 0, -1)
    local object_time = obj.time

    local section_progress = 1
    if obj.frame < obj.totalframe - 1 then
        local i = 1
        while time_marks[i] <= object_time do
            i = i + 1
        end
        i = i - 1
        section_progress = (object_time - time_marks[i]) / (time_marks[i + 1] - time_marks[i])
    end

    local lower_time = 0
    local upper_time = 1

    for i = 1, 10 do
        local mid_time = (lower_time + upper_time) * 0.5
        local curve_x, y = evaluate_bezier(
            mid_time,
            normalized_control_1_x,
            normalized_control_1_y,
            normalized_control_2_x,
            normalized_control_2_y
        )
        if section_progress < curve_x then
            upper_time = mid_time
        else
            lower_time = mid_time
        end
    end

    obj.load("figure", "円", 0xffff00, 20)
    local x, y = evaluate_bezier(
        (lower_time + upper_time) * 0.5,
        normalized_control_1_x,
        normalized_control_1_y,
        normalized_control_2_x,
        normalized_control_2_y
    )
    x = x * graph_size - half_graph_size
    y = -(y * graph_size - half_graph_size)
    obj.draw(x, y)

    obj.load("figure", "四角形", 0x0, graph_size)
    obj.draw(0, 0, 0, 1, 0.5)
    obj.load("figure", "四角形", 0xffffff, graph_size, 5)
    obj.draw()
    obj.load("figure", "円", 0x00ff00, 5)

    for t = 0, 1, 0.01 do
        local x, y = evaluate_bezier(
            t,
            normalized_control_1_x,
            normalized_control_1_y,
            normalized_control_2_x,
            normalized_control_2_y
        )
        x = x * graph_size - half_graph_size
        y = -(y * graph_size - half_graph_size)
        obj.draw(x, y)
    end
    obj.load("figure", "円", 0xff0000, 20)
    obj.draw(control_1_x, control_1_y)
    obj.draw(control_2_x, control_2_y)
    obj.load("tempbuffer")
end
