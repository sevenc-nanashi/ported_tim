--label:${ROOT_CATEGORY}\変形\@スプリット
---$check:上下を揃える
local check_use_single_count = false

---$track:スプリット1
---min=0
---max=100
---step=0.1
local track_progress_1 = 30

---$track:スプリット2
---min=0
---max=100
---step=0.1
local track_progress_2 = 30

---$track:形状
---min=0
---max=300
---step=0.1
local track_shape = 100

---$track:影響範囲
---min=100
---max=1000
---step=0.1
local track_range = 100

---$check:穴だけ開ける
local check_horizontal_only = false

---$track:横分割数
---min=2
---max=100
---step=1
local horizontal_count = 30

---$track:縦分割数
---min=2
---max=100
---step=1
local vertical_count = 30

---$value:位置
local center_line = { -100, 0, 100, 0 }

---$track:透明度境界ボカシ
---min=0
---max=500
---step=0.1
local boundary_blur = 1

--hide@track_progress_2:check_use_single_count==1

local upper_split_progress = track_progress_1 * 0.01
local lower_split_progress = track_progress_2 * 0.01
local shape_ratio = track_shape * 0.01
local range_ratio = track_range * 0.01

if shape_ratio > 1 then
    shape_ratio = 10 * shape_ratio - 9
end

horizontal_count = math.floor(math.abs(horizontal_count))
if horizontal_count < 2 then
    horizontal_count = 2
end
vertical_count = -math.floor(-math.abs(vertical_count / 2))
if vertical_count < 2 then
    vertical_count = 2
end

local w, h = obj.getpixel()
local half_image_width, half_image_height = w * 0.5, h * 0.5
local split_center_x, split_center_y, split_width, split_rotation

if T_SPLIT_CENTER_X == nil then
    obj.setanchor("center_line", 2, "line")
    local dx = center_line[3] - center_line[1]
    local dy = center_line[4] - center_line[2]
    split_center_x = (center_line[1] + center_line[3]) / 2
    split_center_y = (center_line[2] + center_line[4]) / 2
    split_width = math.sqrt(dx * dx + dy * dy)
    split_rotation = math.atan2(dy, dx)
else
    split_center_x = T_SPLIT_CENTER_X
    split_center_y = T_SPLIT_CENTER_Y
    split_width = T_SPLIT_WIDTH
    split_rotation = T_SPLIT_ROTATION
end

--配列の宣言

local x = {}
local z = {}
local upper_vertices_y = {}
local lower_vertices_y = {}
local upper_vertices_x = {}
local lower_vertices_x = {}
local upper_texture_u = {}
local lower_texture_u = {}
local upper_texture_v = {}
local lower_texture_v = {}

for i = 0, horizontal_count do
    upper_vertices_x[i] = {}
    lower_vertices_x[i] = {}
    upper_vertices_y[i] = {}
    lower_vertices_y[i] = {}
    upper_texture_u[i] = {}
    lower_texture_u[i] = {}
    upper_texture_v[i] = {}
    lower_texture_v[i] = {}
end

--基準座標計算

if T_SPLIT_LINE_DATA_MODE == 1 then
    local line_point_count = #T_SPLIT_LINE_DATA
    for i = 0, horizontal_count do
        x[i] = (i - horizontal_count / 2) * 2 / horizontal_count
        local t = (line_point_count - 1) * i / horizontal_count + 1
        local t1 = math.floor(t)
        local t0 = t1 - 1
        local t2 = t1 + 1
        local t3 = t1 + 2
        if t0 < 1 then
            t0 = 1
        end
        if t2 > line_point_count then
            t2 = line_point_count
        end
        if t3 > line_point_count then
            t3 = line_point_count
        end
        z[i] = obj.interpolation(
            t - t1,
            T_SPLIT_LINE_DATA[t0],
            T_SPLIT_LINE_DATA[t1],
            T_SPLIT_LINE_DATA[t2],
            T_SPLIT_LINE_DATA[t3]
        )
    end
elseif T_SPLIT_LINE_DATA_MODE == 2 then
    local line_point_count = #T_SPLIT_LINE_DATA
    for i = 0, horizontal_count do
        x[i] = (i - horizontal_count / 2) * 2 / horizontal_count
        local t = math.floor((line_point_count - 1) * i / horizontal_count + 1.5)
        if t > line_point_count then
            t = line_point_count
        end
        z[i] = T_SPLIT_LINE_DATA[t]
    end
else
    for i = 0, horizontal_count do
        x[i] = (i - horizontal_count / 2) * 2 / horizontal_count
        local absolute_position = math.abs(x[i])
        z[i] = (absolute_position - 1)
            * (absolute_position - 1)
            * (3 * absolute_position * absolute_position + 2 * absolute_position + 1)
    end
end

for i = 0, horizontal_count do
    local upper_displacement = upper_split_progress * (z[i] ^ shape_ratio)
    local lower_displacement = lower_split_progress * (z[i] ^ shape_ratio)

    if check_use_single_count then
        lower_displacement = upper_displacement
    end
    upper_displacement = -upper_displacement

    for j = 0, vertical_count do
        upper_vertices_y[i][j] = upper_displacement * (1 - j / vertical_count) - j / vertical_count
        lower_vertices_y[i][j] = lower_displacement * (1 - j / vertical_count) + j / vertical_count
    end --j
end --i

--表示座標計算
local half_split_width = split_width * 0.5
local half_split_range = half_split_width * range_ratio
local cos = math.cos(split_rotation)
local sin = math.sin(split_rotation)

for i = 0, horizontal_count do
    x[i] = x[i] * half_split_width
    for j = 0, vertical_count do
        upper_vertices_y[i][j] = upper_vertices_y[i][j] * half_split_range
        lower_vertices_y[i][j] = lower_vertices_y[i][j] * half_split_range

        --回転させて、中心ずらす
        upper_vertices_x[i][j], upper_vertices_y[i][j] =
            cos * x[i] - sin * upper_vertices_y[i][j] + split_center_x,
            sin * x[i] + cos * upper_vertices_y[i][j] + split_center_y
        lower_vertices_x[i][j], lower_vertices_y[i][j] =
            cos * x[i] - sin * lower_vertices_y[i][j] + split_center_x,
            sin * x[i] + cos * lower_vertices_y[i][j] + split_center_y
    end --j
end --i

if check_horizontal_only == 0 then
    for j = 0, vertical_count do
        local v = half_split_range * j / vertical_count
        for i = 0, horizontal_count do
            upper_texture_u[i][j], upper_texture_v[i][j] =
                cos * x[i] + sin * v + split_center_x + half_image_width,
                sin * x[i] - cos * v + split_center_y + half_image_height
            lower_texture_u[i][j], lower_texture_v[i][j] =
                cos * x[i] - sin * v + split_center_x + half_image_width,
                sin * x[i] + cos * v + split_center_y + half_image_height
        end
    end
end

--表示
--オリジナルの上に描画、穴あけは、スプリットを回転させた場合のホール対策

obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()

obj.setoption("antialias", 0)
if check_horizontal_only then
    local polygons = {}
    for j = 0, vertical_count - 1 do
        for i = 0, horizontal_count - 1 do
            local x0, y0 = upper_vertices_x[i][j], upper_vertices_y[i][j]
            local x1, y1 = upper_vertices_x[i + 1][j], upper_vertices_y[i + 1][j]
            local x2, y2 = upper_vertices_x[i + 1][j + 1], upper_vertices_y[i + 1][j + 1]
            local x3, y3 = upper_vertices_x[i][j + 1], upper_vertices_y[i][j + 1]
            local u0, v0 = upper_texture_u[i][j], upper_texture_v[i][j]
            local u1, v1 = upper_texture_u[i + 1][j], upper_texture_v[i + 1][j]
            local u2, v2 = upper_texture_u[i + 1][j + 1], upper_texture_v[i + 1][j + 1]
            local u3, v3 = upper_texture_u[i][j + 1], upper_texture_v[i][j + 1]
            table.insert(polygons, { x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, u0, v0, u1, v1, u2, v2, u3, v3 })

            x0, y0 = lower_vertices_x[i][j], lower_vertices_y[i][j]
            x1, y1 = lower_vertices_x[i + 1][j], lower_vertices_y[i + 1][j]
            x2, y2 = lower_vertices_x[i + 1][j + 1], lower_vertices_y[i + 1][j + 1]
            x3, y3 = lower_vertices_x[i][j + 1], lower_vertices_y[i][j + 1]
            u0, v0 = lower_texture_u[i][j], lower_texture_v[i][j]
            u1, v1 = lower_texture_u[i + 1][j], lower_texture_v[i + 1][j]
            u2, v2 = lower_texture_u[i + 1][j + 1], lower_texture_v[i + 1][j + 1]
            u3, v3 = lower_texture_u[i][j + 1], lower_texture_v[i][j + 1]
            table.insert(polygons, { x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, u0, v0, u1, v1, u2, v2, u3, v3 })
        end --i
    end --j
    obj.drawpoly(polygons)
end

--穴あけ
obj.load("figure", "四角形", 0xffffff, math.max(w, h))
obj.setoption("antialias", 1)
obj.setoption("blend", "alpha_sub")
for i = 0, horizontal_count - 1 do
    local x0, y0 = upper_vertices_x[i][0], upper_vertices_y[i][0]
    local x1, y1 = upper_vertices_x[i + 1][0], upper_vertices_y[i + 1][0]
    local x2, y2 = lower_vertices_x[i + 1][0], lower_vertices_y[i + 1][0]
    local x3, y3 = lower_vertices_x[i][0], lower_vertices_y[i][0]
    obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
end

obj.load("tempbuffer")
obj.effect("境界ぼかし", "範囲", boundary_blur, "透明度の境界をぼかす", 1)
--obj.setoption("blend",0)
T_SPLIT_CENTER_X = nil
T_SPLIT_CENTER_Y = nil
T_SPLIT_WIDTH = nil
T_SPLIT_ROTATION = nil
T_SPLIT_LINE_DATA_MODE = nil
