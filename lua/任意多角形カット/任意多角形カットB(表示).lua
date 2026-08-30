--label:${ROOT_CATEGORY}\変形\@任意多角形カット
---$track:厚み
---min=0
---max=1000
---step=0.1
local track_thickness = 0

---$color:側面色
local color_side = ""

---$value:アンチエイリアス
local value_antialias_mode = 0

local function orientation_sign(ax, ay, bx, by)
    if ax * by - ay * bx > 0 then
        return 1
    else
        return -1
    end
end
local function intersection_product(vertex_1, vertex_2, vertex_3, vertex_4)
    return (
        (vertex_1.x - vertex_2.x) * (vertex_3.y - vertex_1.y)
        + (vertex_1.y - vertex_2.y) * (vertex_1.x - vertex_3.x)
    )
        * (
            (vertex_1.x - vertex_2.x) * (vertex_4.y - vertex_1.y)
            + (vertex_1.y - vertex_2.y) * (vertex_1.x - vertex_4.x)
        )
end
local function point_in_triangle(triangle_vertex_1, triangle_vertex_2, triangle_vertex_3, test_point)
    if
        (triangle_vertex_1.x - triangle_vertex_3.x) * (triangle_vertex_1.y - triangle_vertex_2.y)
        == (triangle_vertex_1.x - triangle_vertex_2.x) * (triangle_vertex_1.y - triangle_vertex_3.y)
    then
        return 0
    elseif
        (intersection_product(triangle_vertex_1, triangle_vertex_2, test_point, triangle_vertex_3) < 0)
        or (intersection_product(triangle_vertex_1, triangle_vertex_3, test_point, triangle_vertex_2) < 0)
        or (intersection_product(triangle_vertex_2, triangle_vertex_3, test_point, triangle_vertex_1) < 0)
    then
        return 0
    else
        return 1
    end
end
local half_thickness, zoom, w, h, texture_center_x, texture_center_y, scaled_vertices, original_vertex_count, max_x, max_y, max_radius_squared, furthest_vertex_index, polygon_orientation, found_ear, corner_orientation, contains_vertex
local polygon_cut_state = T_POLYGON_CUT
local active_vertex_count = polygon_cut_state.vertex_count
local vertices = polygon_cut_state.positions

local function draw_triangle(vertex_1, vertex_2, vertex_3)
    if half_thickness == 0 then
        obj.drawpoly(
            vertex_1.x,
            vertex_1.y,
            half_thickness,
            vertex_1.x,
            vertex_1.y,
            half_thickness,
            vertex_2.x,
            vertex_2.y,
            half_thickness,
            vertex_3.x,
            vertex_3.y,
            half_thickness,
            vertex_1.x + texture_center_x,
            vertex_1.y + texture_center_y,
            vertex_1.x + texture_center_x,
            vertex_1.y + texture_center_y,
            vertex_2.x + texture_center_x,
            vertex_2.y + texture_center_y,
            vertex_3.x + texture_center_x,
            vertex_3.y + texture_center_y
        )
    else
        local vertex_1_x, vertex_2_x, vertex_3_x = vertex_1.x * zoom, vertex_2.x * zoom, vertex_3.x * zoom
        local vertex_1_y, vertex_2_y, vertex_3_y = vertex_1.y * zoom, vertex_2.y * zoom, vertex_3.y * zoom
        obj.drawpoly(
            vertex_1_x,
            vertex_1_y,
            half_thickness,
            vertex_1_x,
            vertex_1_y,
            half_thickness,
            vertex_2_x,
            vertex_2_y,
            half_thickness,
            vertex_3_x,
            vertex_3_y,
            half_thickness,
            vertex_1_x + texture_center_x,
            vertex_1_y + texture_center_y,
            vertex_1_x + texture_center_x,
            vertex_1_y + texture_center_y,
            vertex_2_x + texture_center_x,
            vertex_2_y + texture_center_y,
            vertex_3_x + texture_center_x,
            vertex_3_y + texture_center_y
        )
        obj.drawpoly(
            vertex_1_x,
            vertex_1_y,
            -half_thickness,
            vertex_1_x,
            vertex_1_y,
            -half_thickness,
            vertex_2_x,
            vertex_2_y,
            -half_thickness,
            vertex_3_x,
            vertex_3_y,
            -half_thickness,
            vertex_1_x + texture_center_x,
            vertex_1_y + texture_center_y,
            vertex_1_x + texture_center_x,
            vertex_1_y + texture_center_y,
            vertex_2_x + texture_center_x,
            vertex_2_y + texture_center_y,
            vertex_3_x + texture_center_x,
            vertex_3_y + texture_center_y
        )
    end
end

half_thickness = track_thickness / 2
zoom = obj.getvalue("zoom") * 0.01
w, h = obj.getpixel()
if half_thickness == 0 then
    texture_center_x = w / 2
    texture_center_y = w / 2
else
    texture_center_x = obj.w / 2
    texture_center_y = obj.h / 2
end

if half_thickness == 0 then
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.setoption("blend", "alpha_add")
end

obj.setoption("antialias", value_antialias_mode)
scaled_vertices = {}
original_vertex_count = active_vertex_count

vertices[0] = {}
vertices[0] = vertices[active_vertex_count]
vertices[active_vertex_count + 1] = {}
vertices[active_vertex_count + 1] = vertices[1]

for i = 0, active_vertex_count + 1 do
    scaled_vertices[i] = { x = vertices[i].x * zoom, y = vertices[i].y * zoom }
end

max_x = math.abs(vertices[1].x)
max_y = math.abs(vertices[1].y)
max_radius_squared = max_x * max_x + max_y * max_y
furthest_vertex_index = 1
for i = 2, active_vertex_count do
    max_x = math.max(math.abs(vertices[i].x), max_x)
    max_y = math.max(math.abs(vertices[i].y), max_y)
    if max_radius_squared < vertices[i].x * vertices[i].x + vertices[i].y * vertices[i].y then
        max_radius_squared = vertices[i].x * vertices[i].x + vertices[i].y * vertices[i].y
        furthest_vertex_index = i
    end
end

polygon_orientation = orientation_sign(
    vertices[furthest_vertex_index].x - vertices[furthest_vertex_index - 1].x,
    vertices[furthest_vertex_index].y - vertices[furthest_vertex_index - 1].y,
    vertices[furthest_vertex_index + 1].x - vertices[furthest_vertex_index].x,
    vertices[furthest_vertex_index + 1].y - vertices[furthest_vertex_index].y
)
repeat
    local ear_index = 0
    repeat
        found_ear = 0
        ear_index = ear_index + 1
        corner_orientation = orientation_sign(
            vertices[ear_index].x - vertices[ear_index - 1].x,
            vertices[ear_index].y - vertices[ear_index - 1].y,
            vertices[ear_index + 1].x - vertices[ear_index].x,
            vertices[ear_index + 1].y - vertices[ear_index].y
        )
        if corner_orientation == polygon_orientation then
            contains_vertex = 0
            for j = 1, active_vertex_count do
                if j < ear_index - 1 or j > ear_index + 1 then
                    contains_vertex = point_in_triangle(
                        vertices[ear_index - 1],
                        vertices[ear_index],
                        vertices[ear_index + 1],
                        vertices[j]
                    )
                end --if
                if contains_vertex == 1 then
                    break
                end
            end --j
            if contains_vertex == 0 then
                found_ear = 1
            end
        end
    until found_ear == 1
    draw_triangle(vertices[ear_index - 1], vertices[ear_index], vertices[ear_index + 1])
    for j = ear_index + 1, active_vertex_count do
        vertices[j - 1] = vertices[j]
    end
    active_vertex_count = active_vertex_count - 1
    vertices[0] = vertices[active_vertex_count]
    vertices[active_vertex_count + 1] = vertices[1]
until active_vertex_count < 4
draw_triangle(vertices[1], vertices[2], vertices[3])

if half_thickness == 0 then
    obj.load("tempbuffer")
end

if half_thickness ~= 0 then
    obj.setoption("drawtarget", "framebuffer")
    if color_side ~= "" and color_side ~= nil then
        obj.load("figure", "四角形", color_side, 100)
        obj.setoption("antialias", value_antialias_mode)
    end
    for i = 1, original_vertex_count do
        obj.drawpoly(
            scaled_vertices[i].x,
            scaled_vertices[i].y,
            -half_thickness,
            scaled_vertices[i].x,
            scaled_vertices[i].y,
            half_thickness,
            scaled_vertices[i + 1].x,
            scaled_vertices[i + 1].y,
            half_thickness,
            scaled_vertices[i + 1].x,
            scaled_vertices[i + 1].y,
            -half_thickness,
            scaled_vertices[i].x + texture_center_x,
            scaled_vertices[i].y + texture_center_y,
            scaled_vertices[i].x + texture_center_x,
            scaled_vertices[i].y + texture_center_y,
            scaled_vertices[i + 1].x + texture_center_x,
            scaled_vertices[i + 1].y + texture_center_y,
            scaled_vertices[i + 1].x + texture_center_x,
            scaled_vertices[i + 1].y + texture_center_y
        )
    end
end

T_POLYGON_CUT = nil
