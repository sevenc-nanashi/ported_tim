--label:${ROOT_CATEGORY}\カスタムオブジェクト
---$track:アンカー数
---min=1
---max=16
---step=1
local track_anchor_count = 4

---$track:線幅
---min=0
---max=1000
---step=0.1
local track_line_width = 20

---$track:矢尻幅％
---min=0
---max=1000
---step=0.1
local track_arrowhead_width_percent = 200

---$track:矢尻長％
---min=0
---max=1000
---step=0.1
local track_arrowhead_length_percent = 240

---$color:線色
local color_line = 0xff0000

---$string:表示指示
local value_segment_visibility = "10"

---$check:角丸
local check_round_corners = 0

---$check:結合
local check_join_segments = 0

---$track:Xスナップ
---min=1
---max=500
---step=1
local track_snap_x = 30

---$track:Yスナップ
---min=1
---max=500
---step=1
local track_snap_y = 30

---$value:座標
local anchor_positions = { -150, -100, 150, -100, -150, 100, 150, 100 }

---$check:矢印位置反転
local check_reverse_arrow_position = false

--ver1.1

local color_line = color_line or 0xff0000
local value_segment_visibility = value_segment_visibility or 1
local check_round_corners = check_round_corners
local check_join_segments = check_join_segments
local snap_x = math.abs(track_snap_x or 0)
local snap_y = math.abs(track_snap_y or 0)

local anchor_count = track_anchor_count

local line_width = track_line_width
local arrowhead_width = line_width * track_arrowhead_width_percent * 0.01
local arrowhead_length = line_width * track_arrowhead_length_percent * 0.01

obj.setanchor("anchor_positions", anchor_count, "line")

local visibility_pattern_length = string.len(value_segment_visibility)
local segment_visibility = {}
for i = 1, visibility_pattern_length do
    segment_visibility[i] = tonumber(string.sub(value_segment_visibility, i, i))
end

local anchor_x_positions = {}
local anchor_y_positions = {}

for i = 1, anchor_count do
    anchor_x_positions[i] = anchor_positions[2 * i - 1]
    anchor_y_positions[i] = anchor_positions[2 * i]

    if snap_x > 0 then
        anchor_x_positions[i] = anchor_x_positions[i] + snap_x * 0.5
        local snap_index = math.floor(anchor_x_positions[i] / snap_x)
        anchor_x_positions[i] = snap_index * snap_x
    end
    if snap_y > 0 then
        anchor_y_positions[i] = anchor_y_positions[i] + snap_y * 0.5
        local snap_index = math.floor(anchor_y_positions[i] / snap_y)
        anchor_y_positions[i] = snap_index * snap_y
    end

    local pattern_index = ((i - 1) % visibility_pattern_length) + 1
    segment_visibility[i] = segment_visibility[pattern_index]
end

if check_reverse_arrow_position then
    for i = 1, anchor_count / 2 do
        anchor_x_positions[i], anchor_x_positions[anchor_count + 1 - i] =
            anchor_x_positions[anchor_count + 1 - i], anchor_x_positions[i]
        anchor_y_positions[i], anchor_y_positions[anchor_count + 1 - i] =
            anchor_y_positions[anchor_count + 1 - i], anchor_y_positions[i]
        segment_visibility[i], segment_visibility[anchor_count + 0 - i] =
            segment_visibility[anchor_count + 0 - i], segment_visibility[i]
    end
end

local max_x = math.max(unpack(anchor_x_positions))
local min_x = math.min(unpack(anchor_x_positions))
local max_y = math.max(unpack(anchor_y_positions))
local min_y = math.min(unpack(anchor_y_positions))

local center_x = (max_x + min_x) * 0.5
local center_y = (max_y + min_y) * 0.5

for i = 1, anchor_count do
    anchor_x_positions[i] = anchor_x_positions[i] - center_x
    anchor_y_positions[i] = anchor_y_positions[i] - center_y
end

local arrowhead_enabled = {}
if check_join_segments == 1 then
    for i = 1, anchor_count - 2 do
        if segment_visibility[i + 1] == 1 then
            arrowhead_enabled[i] = 0
        else
            arrowhead_enabled[i] = 1
        end
    end

    arrowhead_enabled[anchor_count - 1] = 1
else
    for i = 1, anchor_count - 1 do
        arrowhead_enabled[i] = 1
    end
end

local canvas_margin = math.max(arrowhead_width, line_width)
obj.setoption("drawtarget", "tempbuffer", max_x - min_x + canvas_margin, max_y - min_y + canvas_margin)
obj.setoption("blend", "alpha_add")
obj.load("figure", "四角形", color_line, 1)

for i = 1, anchor_count - 1 do
    if segment_visibility[i] == 1 then
        local arrowhead_length = arrowhead_length * arrowhead_enabled[i] --ahを局所定義

        local segment_delta_x = anchor_x_positions[i + 1] - anchor_x_positions[i]
        local segment_delta_y = anchor_y_positions[i + 1] - anchor_y_positions[i]
        local segment_length = math.sqrt(segment_delta_x * segment_delta_x + segment_delta_y * segment_delta_y)
        local normal_scale = line_width / segment_length * 0.5
        local normal_x = segment_delta_y * normal_scale
        local normal_y = -segment_delta_x * normal_scale

        local x1, y1 = anchor_x_positions[i] - normal_x, anchor_y_positions[i] - normal_y
        local x2, y2 = anchor_x_positions[i] + normal_x, anchor_y_positions[i] + normal_y
        local x = anchor_x_positions[i] + segment_delta_x * (segment_length - arrowhead_length) / segment_length
        local y = anchor_y_positions[i] + segment_delta_y * (segment_length - arrowhead_length) / segment_length
        local x3, y3 = x + normal_x, y + normal_y
        local x4, y4 = x - normal_x, y - normal_y
        obj.drawpoly(x1, y1, 0, x2, y2, 0, x3, y3, 0, x4, y4, 0)

        if arrowhead_length ~= 0 then
            normal_scale = arrowhead_width / segment_length * 0.5
            normal_x = segment_delta_y * normal_scale
            normal_y = -segment_delta_x * normal_scale
            x1, y1 = x + normal_x, y + normal_y
            x2, y2 = x - normal_x, y - normal_y
            obj.drawpoly(
                anchor_x_positions[i + 1],
                anchor_y_positions[i + 1],
                0,
                anchor_x_positions[i + 1],
                anchor_y_positions[i + 1],
                0,
                x1,
                y1,
                0,
                x2,
                y2,
                0
            )
        end
    end
end

if check_round_corners == 1 then
    obj.load("figure", "円", color_line, 2 * line_width)
    if segment_visibility[1] == 1 then
        obj.draw(anchor_x_positions[1], anchor_y_positions[1], 0, 0.5)
    end
    for i = 2, anchor_count - 1 do
        if
            segment_visibility[i] == 1
            or (segment_visibility[i] == 0 and segment_visibility[i - 1] == 1 and arrowhead_length == 0)
        then
            obj.draw(anchor_x_positions[i], anchor_y_positions[i], 0, 0.5)
        end
    end
    if segment_visibility[anchor_count - 1] == 1 and arrowhead_length == 0 then
        obj.draw(anchor_x_positions[anchor_count], anchor_y_positions[anchor_count], 0, 0.5)
    end
end

obj.load("tempbuffer")
obj.center_x = obj.center_x - center_x
obj.center_y = obj.center_y - center_y
