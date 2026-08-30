--label:${ROOT_CATEGORY}\配置\@TrackingラインEasy
---$track:+頂点数
---min=2
---max=16
---step=1
local track_plus_vertex_count = 2

---$check:環状にする
local closed_loop = 0

---$value:座標
local control_points = { 0, 0, 100, 100 }

---$check:頂点追加を無効にする
local disable_vertex_addition = false

--hide@track_plus_vertex_count:disable_vertex_addition==1
--hide@closed_loop:disable_vertex_addition==1
--hide@control_points:disable_vertex_addition==1

if not disable_vertex_addition then
    local vertex_count = track_plus_vertex_count
    obj.setanchor("control_points", vertex_count, "line")
    local group_index = #T_TRACKING.points_x + 1
    T_TRACKING.closed_loop[group_index] = closed_loop or 0
    T_TRACKING.points_x[group_index] = {}
    T_TRACKING.points_y[group_index] = {}
    for i = 1, vertex_count do
        T_TRACKING.points_x[group_index][i] = control_points[2 * i - 1]
        T_TRACKING.points_y[group_index][i] = control_points[2 * i]
    end
end

if obj.getoption("script_name", 1) ~= "TrackingラインEasy(頂点追加)@TrackingラインEasy@tim.anm2" then
    T_TRACKING.draw(T_TRACKING)
    T_TRACKING = nil
end
