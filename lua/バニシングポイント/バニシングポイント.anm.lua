--label:${ROOT_CATEGORY}\変形
---$track:移動X
---min=-50000
---max=50000
---step=0.1
---zero_label=
---scale=0.02
local track_move_x = 0

---$track:移動Y
---min=-50000
---max=50000
---step=0.1
---zero_label=
---scale=0.02
local track_move_y = 0

---$track:浮上X
---min=-20000
---max=20000
---step=0.1
---zero_label=
---scale=0.05
local track_up_x = 0

---$track:浮上Y
---min=-20000
---max=20000
---step=0.1
---zero_label=
---scale=0.05
local track_up_y = 0

---$select:反転
---なし=0
---左右=1
---上下=2
---上下左右=3
local select_reverse = 0

---$check:参照領域
local check_use_reference_area = 1

---$check:オリジナル表示
local check_show_original = 1

---$track:分割数
---min=1
---max=300
---step=1
local track_division_count = 10

-- ---$check:アンチエイリアス
-- local ANT = 1

---$value:領域
local area_vertices = { -80, -100, 80, -105, 100, 105, -100, 100 }

--hide@track_division_count:check_use_reference_area==1

local horizontal_vanishing_point, vertical_vanishing_point, area_center_x, area_center_y, lift_x, lift_y

local function line_intersection(point_a, point_b, point_c, point_d)
    local line_ratio
    local cross_product = (point_d.y - point_c.y) * (point_c.x - point_a.x)
        - (point_d.x - point_c.x) * (point_c.y - point_a.y)
    local denominator = (point_b.x - point_a.x) * (point_d.y - point_c.y)
        - (point_b.y - point_a.y) * (point_d.x - point_c.x)
    if denominator ~= 0 then
        line_ratio = cross_product / denominator
    else
        line_ratio = cross_product > 0 and 2000000000 or -2000000000
    end
    return point_a.x + line_ratio * (point_b.x - point_a.x), point_a.y + line_ratio * (point_b.y - point_a.y)
end

local function orientation_sign(point_a, point_b, point_c, point_d)
    return (point_b.x - point_a.x) * (point_d.y - point_c.y) - (point_b.y - point_a.y) * (point_d.x - point_c.x) > 0
            and -1
        or 1
end

local function lift_rate(position_x, position_y, horizontal_x, horizontal_y, vertical_x, vertical_y)
    return (
        1
        - (position_x * horizontal_x + position_y * horizontal_y)
            / (horizontal_x * horizontal_x + horizontal_y * horizontal_y)
    )
        * (
            1
            - (position_x * vertical_x + position_y * vertical_y)
                / (vertical_x * vertical_x + vertical_y * vertical_y)
        )
end

local function map_position(horizontal_point, vertical_point)
    local mapped_x, mapped_y =
        line_intersection(horizontal_point, vertical_vanishing_point, vertical_point, horizontal_vanishing_point)
    local lift_amount = lift_rate(
        mapped_x - area_center_x,
        mapped_y - area_center_y,
        horizontal_vanishing_point.x - area_center_x,
        horizontal_vanishing_point.y - area_center_y,
        vertical_vanishing_point.x - area_center_x,
        vertical_vanishing_point.y - area_center_y
    )
    return mapped_x + lift_x * lift_amount, mapped_y + lift_y * lift_amount
end

local reverse_mode = select_reverse or 0
local division_count = math.max(1, track_division_count or 10)
obj.setanchor("area_vertices", 4, "loop")
local width, height = obj.getpixel()
local half_width = width / 2
local half_height = height / 2
local source_points = {}
source_points[1] = { x = area_vertices[1], y = area_vertices[2] }
source_points[2] = { x = area_vertices[3], y = area_vertices[4] }
source_points[3] = { x = area_vertices[5], y = area_vertices[6] }
source_points[4] = { x = area_vertices[7], y = area_vertices[8] }

if orientation_sign(source_points[1], source_points[2], source_points[2], source_points[3]) == 1 then
    source_points[1], source_points[2] = source_points[2], source_points[1]
    source_points[3], source_points[4] = source_points[4], source_points[3]
end

local move_x = track_move_x / 100
local move_y = track_move_y / 100

lift_x = track_up_x
lift_y = track_up_y

horizontal_vanishing_point = {}
vertical_vanishing_point = {}
horizontal_vanishing_point.x, horizontal_vanishing_point.y =
    line_intersection(source_points[1], source_points[2], source_points[4], source_points[3])
vertical_vanishing_point.x, vertical_vanishing_point.y =
    line_intersection(source_points[1], source_points[4], source_points[2], source_points[3])

local horizontal_orientation =
    orientation_sign(horizontal_vanishing_point, source_points[1], source_points[1], source_points[4])
local vertical_orientation =
    orientation_sign(vertical_vanishing_point, source_points[2], source_points[2], source_points[1])

local source_top_width =
    math.sqrt((source_points[1].x - source_points[2].x) ^ 2 + (source_points[1].y - source_points[2].y) ^ 2)
local source_left_height =
    math.sqrt((source_points[1].x - source_points[4].x) ^ 2 + (source_points[1].y - source_points[4].y) ^ 2)
local horizontal_vanishing_distance
local vertical_vanishing_distance
if horizontal_orientation > 0 then
    horizontal_vanishing_distance = math.sqrt(
        (source_points[1].x - horizontal_vanishing_point.x) ^ 2
            + (source_points[1].y - horizontal_vanishing_point.y) ^ 2
    )
else
    move_x = -move_x
    horizontal_vanishing_distance = math.sqrt(
        (source_points[2].x - horizontal_vanishing_point.x) ^ 2
            + (source_points[2].y - horizontal_vanishing_point.y) ^ 2
    )
end

if vertical_orientation > 0 then
    vertical_vanishing_distance = math.sqrt(
        (source_points[1].x - vertical_vanishing_point.x) ^ 2 + (source_points[1].y - vertical_vanishing_point.y) ^ 2
    )
else
    move_y = -move_y
    vertical_vanishing_distance = math.sqrt(
        (source_points[4].x - vertical_vanishing_point.x) ^ 2 + (source_points[4].y - vertical_vanishing_point.y) ^ 2
    )
end

area_center_x = (source_points[1].x + source_points[2].x + source_points[3].x + source_points[4].x) / 4
area_center_y = (source_points[1].y + source_points[2].y + source_points[3].y + source_points[4].y) / 4

local horizontal_perspective_ratio = 1 - source_top_width / horizontal_vanishing_distance
local vertical_perspective_ratio = 1 - source_left_height / vertical_vanishing_distance

local horizontal_ratio_1 = (1 - horizontal_perspective_ratio ^ move_x) / (1 - horizontal_perspective_ratio)
local horizontal_ratio_2 = (1 - horizontal_perspective_ratio ^ (move_x + 1)) / (1 - horizontal_perspective_ratio)
local horizontal_points = {}

if horizontal_orientation > 0 then
    horizontal_points[1] = {
        x = source_points[1].x + (source_points[2].x - source_points[1].x) * horizontal_ratio_1,
        y = source_points[1].y + (source_points[2].y - source_points[1].y) * horizontal_ratio_1,
    }
    horizontal_points[2] = {
        x = source_points[1].x + (source_points[2].x - source_points[1].x) * horizontal_ratio_2,
        y = source_points[1].y + (source_points[2].y - source_points[1].y) * horizontal_ratio_2,
    }
else
    horizontal_points[2] = {
        x = source_points[2].x + (source_points[1].x - source_points[2].x) * horizontal_ratio_1,
        y = source_points[2].y + (source_points[1].y - source_points[2].y) * horizontal_ratio_1,
    }
    horizontal_points[1] = {
        x = source_points[2].x + (source_points[1].x - source_points[2].x) * horizontal_ratio_2,
        y = source_points[2].y + (source_points[1].y - source_points[2].y) * horizontal_ratio_2,
    }
end

local vertical_ratio_1 = (1 - vertical_perspective_ratio ^ move_y) / (1 - vertical_perspective_ratio)
local vertical_ratio_2 = (1 - vertical_perspective_ratio ^ (1 + move_y)) / (1 - vertical_perspective_ratio)
local vertical_points = {}

if vertical_orientation > 0 then
    vertical_points[1] = {
        x = source_points[1].x + (source_points[4].x - source_points[1].x) * vertical_ratio_1,
        y = source_points[1].y + (source_points[4].y - source_points[1].y) * vertical_ratio_1,
    }
    vertical_points[2] = {
        x = source_points[1].x + (source_points[4].x - source_points[1].x) * vertical_ratio_2,
        y = source_points[1].y + (source_points[4].y - source_points[1].y) * vertical_ratio_2,
    }
else
    vertical_points[2] = {
        x = source_points[4].x + (source_points[1].x - source_points[4].x) * vertical_ratio_1,
        y = source_points[4].y + (source_points[1].y - source_points[4].y) * vertical_ratio_1,
    }
    vertical_points[1] = {
        x = source_points[4].x + (source_points[1].x - source_points[4].x) * vertical_ratio_2,
        y = source_points[4].y + (source_points[1].y - source_points[4].y) * vertical_ratio_2,
    }
end

local x0, y0 = map_position(horizontal_points[1], vertical_points[1])
local x1, y1 = map_position(horizontal_points[2], vertical_points[1])
local x2, y2 = map_position(horizontal_points[2], vertical_points[2])
local x3, y3 = map_position(horizontal_points[1], vertical_points[2])

local output_max_x, output_max_y, output_min_x, output_min_y
if check_show_original == 1 then
    output_max_x = math.max(x3, x2, x1, x0, half_width)
    output_max_y = math.max(y3, y2, y1, y0, half_height)
    output_min_x = math.min(x3, x2, x1, x0, -half_width)
    output_min_y = math.min(y3, y2, y1, y0, -half_height)
else
    output_max_x = math.max(x3, x2, x1, x0)
    output_max_y = math.max(y3, y2, y1, y0)
    output_min_x = math.min(x3, x2, x1, x0)
    output_min_y = math.min(y3, y2, y1, y0)
end

local output_width = output_max_x - output_min_x
local output_height = output_max_y - output_min_y
local output_center_x = (output_max_x + output_min_x) / 2
local output_center_y = (output_max_y + output_min_y) / 2

obj.setoption("drawtarget", "tempbuffer", output_width, output_height)
-- obj.setoption("antialias", ANT)

if check_show_original == 1 then
    obj.draw(-output_center_x, -output_center_y, 0)
else
    obj.setoption("blend", "alpha_add")
end

if check_use_reference_area == 1 then
    x0, x1, x2, x3 = x0 - output_center_x, x1 - output_center_x, x2 - output_center_x, x3 - output_center_x
    y0, y1, y2, y3 = y0 - output_center_y, y1 - output_center_y, y2 - output_center_y, y3 - output_center_y
    local u0, v0, u1, v1, u2, v2, u3, v3 =
        source_points[1].x + half_width,
        source_points[1].y + half_height,
        source_points[2].x + half_width,
        source_points[2].y + half_height,
        source_points[3].x + half_width,
        source_points[3].y + half_height,
        source_points[4].x + half_width,
        source_points[4].y + half_height

    if AND(reverse_mode, 1) == 1 then
        u0, v0, u1, v1 = u1, v1, u0, v0
        u2, v2, u3, v3 = u3, v3, u2, v2
    end

    if AND(reverse_mode, 2) == 2 then
        u0, v0, u3, v3 = u3, v3, u0, v0
        u2, v2, u1, v1 = u1, v1, u2, v2
    end

    obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, u0, v0, u1, v1, u2, v2, u3, v3)
else
    local vertices = {}
    for i = 0, division_count - 1 do
        for j = 0, division_count - 1 do
            local horizontal_ratio_1 = (1 - horizontal_perspective_ratio ^ (move_x + i / division_count))
                / (1 - horizontal_perspective_ratio)
            local horizontal_ratio_2 = (1 - horizontal_perspective_ratio ^ (move_x + (i + 1) / division_count))
                / (1 - horizontal_perspective_ratio)
            local horizontal_points = {}

            if horizontal_orientation > 0 then
                horizontal_points[1] = {
                    x = source_points[1].x + (source_points[2].x - source_points[1].x) * horizontal_ratio_1,
                    y = source_points[1].y + (source_points[2].y - source_points[1].y) * horizontal_ratio_1,
                }
                horizontal_points[2] = {
                    x = source_points[1].x + (source_points[2].x - source_points[1].x) * horizontal_ratio_2,
                    y = source_points[1].y + (source_points[2].y - source_points[1].y) * horizontal_ratio_2,
                }
            else
                horizontal_points[2] = {
                    x = source_points[2].x + (source_points[1].x - source_points[2].x) * horizontal_ratio_1,
                    y = source_points[2].y + (source_points[1].y - source_points[2].y) * horizontal_ratio_1,
                }
                horizontal_points[1] = {
                    x = source_points[2].x + (source_points[1].x - source_points[2].x) * horizontal_ratio_2,
                    y = source_points[2].y + (source_points[1].y - source_points[2].y) * horizontal_ratio_2,
                }
            end

            local vertical_ratio_1 = (1 - vertical_perspective_ratio ^ (move_y + j / division_count))
                / (1 - vertical_perspective_ratio)
            local vertical_ratio_2 = (1 - vertical_perspective_ratio ^ (move_y + (j + 1) / division_count))
                / (1 - vertical_perspective_ratio)
            local vertical_points = {}

            if vertical_orientation > 0 then
                vertical_points[1] = {
                    x = source_points[1].x + (source_points[4].x - source_points[1].x) * vertical_ratio_1,
                    y = source_points[1].y + (source_points[4].y - source_points[1].y) * vertical_ratio_1,
                }
                vertical_points[2] = {
                    x = source_points[1].x + (source_points[4].x - source_points[1].x) * vertical_ratio_2,
                    y = source_points[1].y + (source_points[4].y - source_points[1].y) * vertical_ratio_2,
                }
            else
                vertical_points[2] = {
                    x = source_points[4].x + (source_points[1].x - source_points[4].x) * vertical_ratio_1,
                    y = source_points[4].y + (source_points[1].y - source_points[4].y) * vertical_ratio_1,
                }
                vertical_points[1] = {
                    x = source_points[4].x + (source_points[1].x - source_points[4].x) * vertical_ratio_2,
                    y = source_points[4].y + (source_points[1].y - source_points[4].y) * vertical_ratio_2,
                }
            end

            local x0, y0 = map_position(horizontal_points[1], vertical_points[1])
            local x1, y1 = map_position(horizontal_points[2], vertical_points[1])
            local x2, y2 = map_position(horizontal_points[2], vertical_points[2])
            local x3, y3 = map_position(horizontal_points[1], vertical_points[2])
            local u0, u1, v0, v1

            if horizontal_orientation < 0 then
                u1 = width * (1 - i / division_count)
                u0 = width * (1 - (i + 1) / division_count)
            else
                u0 = width * i / division_count
                u1 = width * (i + 1) / division_count
            end

            if vertical_orientation > 0 then
                v0 = height * j / division_count
                v1 = height * (j + 1) / division_count
            else
                v1 = height * (1 - j / division_count)
                v0 = height * (1 - (j + 1) / division_count)
            end

            x0, x1, x2, x3 = x0 - output_center_x, x1 - output_center_x, x2 - output_center_x, x3 - output_center_x
            y0, y1, y2, y3 = y0 - output_center_y, y1 - output_center_y, y2 - output_center_y, y3 - output_center_y

            if AND(reverse_mode, 1) == 1 then
                u0, u1 = width - u0, width - u1
            end

            if AND(reverse_mode, 2) == 2 then
                v0, v1 = height - v0, height - v1
            end

            vertices[#vertices + 1] = { x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, u0, v0, u1, v0, u1, v1, u0, v1 }
        end
    end
    if #vertices > 0 then
        obj.drawpoly(vertices)
    end
end

obj.load("tempbuffer")

obj.cx = obj.cx - output_center_x
obj.cy = obj.cy - output_center_y
