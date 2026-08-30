--label:${ROOT_CATEGORY}\変形\@任意多角形カット
---$track:頂点数
---min=1
---max=16
---step=1
local track_vertex_count = 4

---$value:領域
local value_polygon_vertices = { -100, -100, 100, -100, 100, 100, -100, 100 }

T_POLYGON_CUT = T_POLYGON_CUT or { positions = {}, vertex_count = 0 }
local polygon_cut_state = T_POLYGON_CUT
local added_vertex_count = track_vertex_count
obj.setanchor("value_polygon_vertices", added_vertex_count, "line")
for i = 1, added_vertex_count do
    polygon_cut_state.positions[polygon_cut_state.vertex_count + i] = {}
    polygon_cut_state.positions[polygon_cut_state.vertex_count + i].x = value_polygon_vertices[2 * i - 1]
    polygon_cut_state.positions[polygon_cut_state.vertex_count + i].y = value_polygon_vertices[2 * i]
end
polygon_cut_state.vertex_count = polygon_cut_state.vertex_count + added_vertex_count
