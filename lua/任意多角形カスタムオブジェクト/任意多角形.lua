--label:${ROOT_CATEGORY}\カスタムオブジェクト\@任意多角形
local orientation, side_product, is_point_inside_triangle, draw_triangle, half_thickness, vertex_count, original_vertex_count, vertices, original_vertices, max_x, max_y, maximum_radius_squared, farthest_vertex_index, polygon_orientation, ear_found, vertex_orientation, contains_other_vertex
---$color:色
local fill_color = 0xffffff

--group:ガイド
---$check:ガイド表示
local check_show_guide = false

---$track:ガイドサイズ
---min=0
---max=1000
---step=0.1
local track_guide_size = 50

---$track:厚み
---min=0
---max=1000
---step=0.1
local track_thickness = 0

---$color:ガイド色
local guide_color = 0xff0000

---$figure:図形
local guide_figure = "円"

--hide@track_guide_size:check_show_guide==0
--hide@guide_color:check_show_guide==0
--hide@guide_figure:check_show_guide==0

function orientation(vector_a_x, vector_a_y, vector_b_x, vector_b_y)
    if vector_a_x * vector_b_y - vector_a_y * vector_b_x > 0 then
        return 1
    else
        return -1
    end
end

function side_product(segment_point_1, segment_point_2, segment_point_3, segment_point_4)
    return (
        (segment_point_1.x - segment_point_2.x) * (segment_point_3.y - segment_point_1.y)
        + (segment_point_1.y - segment_point_2.y) * (segment_point_1.x - segment_point_3.x)
    )
        * (
            (segment_point_1.x - segment_point_2.x) * (segment_point_4.y - segment_point_1.y)
            + (segment_point_1.y - segment_point_2.y) * (segment_point_1.x - segment_point_4.x)
        )
end

function is_point_inside_triangle(triangle_point_1, triangle_point_2, triangle_point_3, test_point)
    if
        (triangle_point_1.x - triangle_point_3.x) * (triangle_point_1.y - triangle_point_2.y)
        == (triangle_point_1.x - triangle_point_2.x) * (triangle_point_1.y - triangle_point_3.y)
    then
        return 0
    elseif
        (side_product(triangle_point_1, triangle_point_2, test_point, triangle_point_3) < 0)
        or (side_product(triangle_point_1, triangle_point_3, test_point, triangle_point_2) < 0)
        or (side_product(triangle_point_2, triangle_point_3, test_point, triangle_point_1) < 0)
    then
        return 0
    else
        return 1
    end
end

function draw_triangle(segment_point_1, segment_point_2, segment_point_3)
    obj.drawpoly(
        segment_point_1.x,
        segment_point_1.y,
        0,
        segment_point_1.x,
        segment_point_1.y,
        0,
        segment_point_2.x,
        segment_point_2.y,
        0,
        segment_point_3.x,
        segment_point_3.y,
        0
    )
end

local guide_size = track_guide_size
half_thickness = track_thickness / 2
vertex_count = obj.getoption("section_num") + 1
original_vertex_count = vertex_count
vertices = {}
for i = 1, vertex_count - 1 do
    vertices[i] = {}
    vertices[i].x = obj.getvalue("x", 0, i - 1)
    vertices[i].y = obj.getvalue("y", 0, i - 1)
end
vertices[vertex_count] = {}
vertices[vertex_count].x = obj.getvalue("x", 0, -1)
vertices[vertex_count].y = obj.getvalue("y", 0, -1)
vertices[0] = {}
vertices[0] = vertices[vertex_count]
vertices[vertex_count + 1] = {}
vertices[vertex_count + 1] = vertices[1]

original_vertices = {}
for i = 0, vertex_count + 1 do
    original_vertices[i] = {}
    original_vertices[i].x = vertices[i].x
    original_vertices[i].y = vertices[i].y
end

if check_show_guide then
    obj.load("figure", guide_figure, guide_color, guide_size)
    obj.effect("縁取り")
    for i = 1, vertex_count do
        vertices[i].x = vertices[i].x - obj.getvalue("x")
        vertices[i].y = vertices[i].y - obj.getvalue("y")
        obj.draw(vertices[i].x, vertices[i].y)
    end
    obj.load("figure", "四角形", fill_color, guide_size)
end

if vertex_count < 3 then
    return
end

max_x = math.abs(vertices[1].x)
max_y = math.abs(vertices[1].y)
maximum_radius_squared = max_x * max_x + max_y * max_y
farthest_vertex_index = 1
for i = 2, vertex_count do
    max_x = math.max(math.abs(vertices[i].x), max_x)
    max_y = math.max(math.abs(vertices[i].y), max_y)
    if maximum_radius_squared < vertices[i].x * vertices[i].x + vertices[i].y * vertices[i].y then
        maximum_radius_squared = vertices[i].x * vertices[i].x + vertices[i].y * vertices[i].y
        farthest_vertex_index = i
    end
end

if not check_show_guide then
    obj.load("figure", "四角形", fill_color, 2 * math.max(max_x, max_y))
end

if not check_show_guide then
    obj.setoption("drawtarget", "tempbuffer", 2 * max_x, 2 * max_y)
    obj.setoption("blend", "alpha_add")
end

polygon_orientation = orientation(
    vertices[farthest_vertex_index].x - vertices[farthest_vertex_index - 1].x,
    vertices[farthest_vertex_index].y - vertices[farthest_vertex_index - 1].y,
    vertices[farthest_vertex_index + 1].x - vertices[farthest_vertex_index].x,
    vertices[farthest_vertex_index + 1].y - vertices[farthest_vertex_index].y
)
repeat
    i = 0
    repeat
        ear_found = 0
        i = i + 1
        vertex_orientation = orientation(
            vertices[i].x - vertices[i - 1].x,
            vertices[i].y - vertices[i - 1].y,
            vertices[i + 1].x - vertices[i].x,
            vertices[i + 1].y - vertices[i].y
        )
        if vertex_orientation == polygon_orientation then
            contains_other_vertex = 0
            for j = 1, vertex_count do
                if j < i - 1 or j > i + 1 then
                    contains_other_vertex =
                        is_point_inside_triangle(vertices[i - 1], vertices[i], vertices[i + 1], vertices[j])
                end --if
                if contains_other_vertex == 1 then
                    break
                end
            end --j
            if contains_other_vertex == 0 then
                ear_found = 1
            end
        end
    until ear_found == 1
    draw_triangle(vertices[i - 1], vertices[i], vertices[i + 1])
    for j = i + 1, vertex_count do
        vertices[j - 1] = vertices[j]
    end
    vertex_count = vertex_count - 1
    vertices[0] = vertices[vertex_count]
    vertices[vertex_count + 1] = vertices[1]
until vertex_count < 4
draw_triangle(vertices[1], vertices[2], vertices[3])
if not check_show_guide then
    obj.load("tempbuffer")
    obj.ox = -obj.getvalue("x")
    obj.oy = -obj.getvalue("y")

    if half_thickness ~= 0 then
        obj.setoption("drawtarget", "frame")
        obj.oz = half_thickness
        obj.draw()
        obj.oz = -half_thickness
        obj.draw()
        obj.load("figure", "四角形", fill_color, 500)
        for i = 0, original_vertex_count + 1 do
            original_vertices[i].x = original_vertices[i].x - obj.getvalue("x")
            original_vertices[i].y = original_vertices[i].y - obj.getvalue("y")
        end
        for i = 1, original_vertex_count do
            obj.drawpoly(
                original_vertices[i].x,
                original_vertices[i].y,
                -half_thickness,
                original_vertices[i].x,
                original_vertices[i].y,
                half_thickness,
                original_vertices[i + 1].x,
                original_vertices[i + 1].y,
                half_thickness,
                original_vertices[i + 1].x,
                original_vertices[i + 1].y,
                -half_thickness
            )
        end
    end
end
