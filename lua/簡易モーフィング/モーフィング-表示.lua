--label:${ROOT_CATEGORY}\変形\@モーフィング
---$track:変化度
---min=0
---max=100
---step=0.1
local track_change_amount = 50

---$track:ポイントサイズ
---min=0
---max=500
---step=1
local track_point_size = 30

---$track:フォントサイズ
---min=0
---max=500
---step=1
local track_font_size = 30

---$check:レイヤースクリプト1
local layer_script_1 = 1

---$check:レイヤースクリプト2
local layer_script_2 = 1

---$check:ライン表示
local check_show_lines = 1

---$color:線色
local line_color = 0xffffff

---$track:線幅
---min=0
---max=1000
---step=0.1
local track_line_width = 3

---$check:ポイント表示
local check_show_points = 1

---$color:ポイント色
local point_color = 0xffffff

---$color:文字色
local label_color = 0x0

---$check:ガイド表示
local check_show_guide = false

--hide@check_show_lines:check_show_guide==0
--hide@line_color:check_show_guide==0
--hide@line_color:check_show_lines==0
--hide@track_line_width:check_show_guide==0
--hide@track_line_width:check_show_lines==0
--hide@check_show_points:check_show_guide==0
--hide@track_point_size:check_show_guide==0
--hide@track_point_size:check_show_points==0
--hide@track_font_size:check_show_guide==0
--hide@track_font_size:check_show_points==0
--hide@point_color:check_show_guide==0
--hide@point_color:check_show_points==0
--hide@label_color:check_show_guide==0
--hide@label_color:check_show_points==0

(function()
    local triangulate_points = function(point_count)
        local is_inside_circumcircle = function(p1, p2, p3, test_point) --外接円より内部（境界含まない）なら真
            if
                (p1.x == test_point.x and p1.y == test_point.y)
                or (p2.x == test_point.x and p2.y == test_point.y)
                or (p3.x == test_point.x and p3.y == test_point.y)
            then
                return false
            end

            local circumcircle_denominator = 2 * ((p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x))
            local circumcircle_center_x = (
                (p3.y - p1.y) * (p2.x ^ 2 - p1.x ^ 2 + p2.y ^ 2 - p1.y ^ 2)
                + (p1.y - p2.y) * (p3.x ^ 2 - p1.x ^ 2 + p3.y ^ 2 - p1.y ^ 2)
            ) / circumcircle_denominator
            local circumcircle_center_y = (
                (p1.x - p3.x) * (p2.x ^ 2 - p1.x ^ 2 + p2.y ^ 2 - p1.y ^ 2)
                + (p2.x - p1.x) * (p3.x ^ 2 - p1.x ^ 2 + p3.y ^ 2 - p1.y ^ 2)
            ) / circumcircle_denominator
            if
                (p1.x - circumcircle_center_x) ^ 2 + (p1.y - circumcircle_center_y) ^ 2
                > (test_point.x - circumcircle_center_x) ^ 2 + (test_point.y - circumcircle_center_y) ^ 2
            then
                return true
            else
                return false
            end
        end

        local function add_triangles_around_point(triangles, removed_triangles, added_point_index)
            local boundary_edges = {}
            boundary_edges[1] = { removed_triangles[1][1], removed_triangles[1][2] }
            boundary_edges[2] = { removed_triangles[1][2], removed_triangles[1][3] }
            boundary_edges[3] = { removed_triangles[1][3], removed_triangles[1][1] }
            for i = 2, #removed_triangles do
                local triangle_edges = {
                    removed_triangles[i][1],
                    removed_triangles[i][2],
                    removed_triangles[i][3],
                    removed_triangles[i][1],
                }
                for k = 1, 3 do
                    local should_add_edge = 1
                    for j = 1, #boundary_edges do
                        if
                            boundary_edges[j][1] == triangle_edges[k + 1]
                            and boundary_edges[j][2] == triangle_edges[k]
                        then
                            table.remove(boundary_edges, j)
                            should_add_edge = 0
                            break
                        end
                    end
                    if should_add_edge == 1 then
                        boundary_edges[#boundary_edges + 1] = { triangle_edges[k], triangle_edges[k + 1] }
                    end
                end
            end
            for i = 1, #boundary_edges do
                triangles[#triangles + 1] = { boundary_edges[i][1], boundary_edges[i][2], added_point_index }
            end
        end

        local source_positions = T_MORPHING_OBJECTS[1].pos

        local triangles = {}
        triangles[1] = { 1, 2, 4 }
        triangles[2] = { 2, 3, 4 }

        for i = 5, point_count do
            local removed_triangles = {}
            local j = 1
            repeat --MTをMTとDMTに分離　DMTはiが外接円内部にある
                local p1, p2, p3 = unpack(triangles[j])
                if
                    is_inside_circumcircle(
                        source_positions[p1],
                        source_positions[p2],
                        source_positions[p3],
                        source_positions[i]
                    )
                then
                    removed_triangles[#removed_triangles + 1] = triangles[j]
                    triangles[j] = triangles[#triangles]
                    triangles[#triangles] = nil
                else
                    j = j + 1
                end
            until j > #triangles
            add_triangles_around_point(triangles, removed_triangles, i)
        end

        return triangles
    end

    if T_MORPHING_OBJECTS[1] == nil and T_MORPHING_OBJECTS[2] == nil then
        T_MORPHING_OBJECTS = nil
        return 0
    elseif T_MORPHING_OBJECTS[1] == nil then
        T_MORPHING_OBJECTS[1] = T_MORPHING_OBJECTS[2]
    elseif T_MORPHING_OBJECTS[2] == nil then
        T_MORPHING_OBJECTS[2] = T_MORPHING_OBJECTS[1]
    end

    local blend_ratio = (T_MORPHING_IMPORT or track_change_amount) * 0.01

    local include_layer_effects = {}
    include_layer_effects[1] = (layer_script_1 == 1) and true
    include_layer_effects[2] = (layer_script_2 == 1) and true

    T_MORPHING_OBJECTS[3] = {}
    local source_object = T_MORPHING_OBJECTS[1]
    local target_object = T_MORPHING_OBJECTS[2]
    local morphed_object = T_MORPHING_OBJECTS[3]

    local point_count = math.min(#source_object.pos, #target_object.pos)
    local canvas_width = math.max(source_object.w, target_object.w)
    local canvas_height = math.max(source_object.h, target_object.h)

    local triangles = triangulate_points(point_count)

    morphed_object.pos = {}
    for i = 1, point_count do
        morphed_object.pos[i] = {}
        morphed_object.pos[i].x = source_object.pos[i].x * (1 - blend_ratio) + target_object.pos[i].x * blend_ratio
        morphed_object.pos[i].y = source_object.pos[i].y * (1 - blend_ratio) + target_object.pos[i].y * blend_ratio
    end

    for source_index = 1, 2 do
        local source_object_data = T_MORPHING_OBJECTS[source_index]
        obj.load("layer", source_object_data.layer, include_layer_effects[source_index])
        obj.setoption("drawtarget", "tempbuffer", canvas_width, canvas_height)
        obj.setoption("blend", "alpha_add")
        local source_half_width = source_object_data.w * 0.5
        local source_half_height = source_object_data.h * 0.5
        for i = 1, #triangles do
            local x1 = morphed_object.pos[triangles[i][1]].x
            local y1 = morphed_object.pos[triangles[i][1]].y
            local x2 = morphed_object.pos[triangles[i][2]].x
            local y2 = morphed_object.pos[triangles[i][2]].y
            local x3 = morphed_object.pos[triangles[i][3]].x
            local y3 = morphed_object.pos[triangles[i][3]].y

            local u1 = source_object_data.pos[triangles[i][1]].x + source_half_width
            local v1 = source_object_data.pos[triangles[i][1]].y + source_half_height
            local u2 = source_object_data.pos[triangles[i][2]].x + source_half_width
            local v2 = source_object_data.pos[triangles[i][2]].y + source_half_height
            local u3 = source_object_data.pos[triangles[i][3]].x + source_half_width
            local v3 = source_object_data.pos[triangles[i][3]].y + source_half_height

            obj.drawpoly(x1, y1, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, u1, v1, u1, v1, u2, v2, u3, v3)
        end
        obj.copybuffer("cache:img" .. source_index, "tempbuffer")
    end

    obj.setoption("drawtarget", "tempbuffer", canvas_width, canvas_height)
    obj.copybuffer("object", "cache:img1")
    obj.setoption("blend", 0)
    obj.draw(0, 0, 0, 1, 1 - blend_ratio)

    obj.copybuffer("object", "cache:img2")
    obj.setoption("blend", "alpha_add")
    obj.draw(0, 0, 0, 1, blend_ratio)

    obj.setoption("blend", 0)

    if check_show_lines == 1 and check_show_guide then
        local draw_line = function(x1, y1, x2, y2, line_width)
            local dx = x2 - x1
            local dy = y2 - y1
            local line_length = math.sqrt(dx * dx + dy * dy)
            local normal_offset_x = dy * line_width * 0.5 / line_length
            local normal_offset_y = -dx * line_width * 0.5 / line_length
            obj.drawpoly(
                x2 - normal_offset_x,
                y2 - normal_offset_y,
                0,
                x1 - normal_offset_x,
                y1 - normal_offset_y,
                0,
                x1 + normal_offset_x,
                y1 + normal_offset_y,
                0,
                x2 + normal_offset_x,
                y2 + normal_offset_y,
                0
            )
        end
        obj.load("figure", "四角形", line_color, 1) --math.min(w*0.5,h*0.5))
        for i = 1, #triangles do
            local x1 = morphed_object.pos[triangles[i][1]].x
            local y1 = morphed_object.pos[triangles[i][1]].y
            local x2 = morphed_object.pos[triangles[i][2]].x
            local y2 = morphed_object.pos[triangles[i][2]].y
            local x3 = morphed_object.pos[triangles[i][3]].x
            local y3 = morphed_object.pos[triangles[i][3]].y
            draw_line(x1, y1, x2, y2, track_line_width)
            draw_line(x2, y2, x3, y3, track_line_width)
            draw_line(x3, y3, x1, y1, track_line_width)
        end
    end

    if check_show_points == 1 and check_show_guide then
        obj.load("figure", "円", point_color, track_point_size)
        for i = 1, point_count do
            obj.draw(morphed_object.pos[i].x, morphed_object.pos[i].y)
        end

        obj.setfont("", track_font_size, 0, label_color)
        for i = 1, point_count do
            obj.load("text", i)
            obj.draw(morphed_object.pos[i].x, morphed_object.pos[i].y)
        end
    end

    obj.load("tempbuffer")
    T_MORPHING_OBJECTS = nil
    T_MORPHING_IMPORT = nil
end)()
