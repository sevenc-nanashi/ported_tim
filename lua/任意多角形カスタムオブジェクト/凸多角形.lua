--label:${ROOT_CATEGORY}\カスタムオブジェクト\@任意多角形
local half_thickness, vertex_count, original_vertex_count

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

local guide_size = track_guide_size
half_thickness = track_thickness / 2
vertex_count = obj.getoption("section_num") + 1
original_vertex_count = vertex_count
local vertices = {}
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

local original_vertices = {}
for i = 0, vertex_count + 1 do
    original_vertices[i] = {}
    original_vertices[i].x = vertices[i].x
    original_vertices[i].y = vertices[i].y
end

obj.load("figure", guide_figure, guide_color, guide_size)

if check_show_guide then
    obj.load("figure", guide_figure, guide_color, guide_size)
    obj.effect("縁取り")
    for i = 1, vertex_count do
        vertices[i].x = vertices[i].x - obj.getvalue("x")
        vertices[i].y = vertices[i].y - obj.getvalue("y")
        obj.draw(vertices[i].x, vertices[i].y)
    end
else
    local max_x = math.abs(vertices[1].x)
    local max_y = math.abs(vertices[1].y)
    for i = 2, vertex_count do
        max_x = math.max(math.abs(vertices[i].x), max_x)
        max_y = math.max(math.abs(vertices[i].y), max_y)
    end

    obj.load("figure", "四角形", fill_color, 2 * math.max(max_x, max_y) + 10)

    for i = 1, vertex_count do
        local edge_angle_degrees = math.atan2(vertices[i + 1].y - vertices[i].y, vertices[i + 1].x - vertices[i].x)
                * 180
                / math.pi
            + 180
        local clipping_center_x, clipping_center_y
        if math.abs(vertices[i + 1].x - vertices[i].x) > math.abs(vertices[i + 1].y - vertices[i].y) then
            clipping_center_x = 0
            clipping_center_y = -vertices[i].x
                    * (vertices[i + 1].y - vertices[i].y)
                    / (vertices[i + 1].x - vertices[i].x)
                + vertices[i].y
        else
            clipping_center_x = -vertices[i].y
                    * (vertices[i + 1].x - vertices[i].x)
                    / (vertices[i + 1].y - vertices[i].y)
                + vertices[i].x
            clipping_center_y = 0
        end
        obj.effect(
            "斜めクリッピング",
            "角度",
            edge_angle_degrees + 180,
            "中心X",
            clipping_center_x,
            "中心Y",
            clipping_center_y
        )
    end
    obj.ox = -obj.getvalue("x")
    obj.oy = -obj.getvalue("y")

    if half_thickness ~= 0 then
        obj.setoption("drawtarget", "framebuffer")
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
